//
//  MultiplayerGameState.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 05/08/25.
//

import SwiftUI
import Combine
import Foundation
import Firebase

final class MultiplayerGameState: ObservableObject {
    @Published var currentUser: Player?
    @Published var gameRoom: GameRoom?
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // UI State
    @Published var playerName: String = ""
    @Published var roomCode: String = ""
    @Published var showingRoomCreation = false
    @Published var showingRoomJoining = false
    
    // Player Click State
    @Published var playerMarkedNumbers: [Int] = []
    @Published var shouldHighlightCurrentNumber = false
    @Published var hasPlayerMarkedCurrentNumber = false
    
    private let firebaseService = FirebaseService()
    private var cancellables = Set<AnyCancellable>()
    private var roomListener: AnyCancellable?
    private var connectionCancellable: AnyCancellable?
    
    enum ConnectionStatus: String {
        case disconnected = "disconnected"
        case connecting = "connecting"
        case connected = "connected"
        case inRoom = "inRoom"
        case playing = "playing"
    }
    
    init() {
        print("🔍 Initializing MultiplayerGameState")
        checkFirebaseConnection()
        startConnectionMonitor()
    }
    
    private func checkFirebaseConnection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if FirebaseApp.app() != nil {
                print("✅ Firebase available in MultiplayerGameState")
                self.connectionStatus = .disconnected
                self.errorMessage = nil
            } else {
                print("❌ Firebase not available in MultiplayerGameState")
                self.errorMessage = "Firebase not configured properly"
                self.connectionStatus = .disconnected
            }
        }
    }

    private func startConnectionMonitor() {
        connectionCancellable?.cancel()
        connectionCancellable = firebaseService.listenToConnection()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected {
                    if self.connectionStatus == .disconnected {
                        self.connectionStatus = .connected
                    }
                } else {
                    self.connectionStatus = .disconnected
                }
            }
    }
    
    func initializeForNewSession() {
        print("🎮 Initializing new multiplayer session")
        
        // Reset game state but keep connection info
        gameRoom = nil
        currentUser = nil
        errorMessage = nil
        isLoading = false
        playerMarkedNumbers = []
        hasPlayerMarkedCurrentNumber = false
        shouldHighlightCurrentNumber = false
        showingRoomCreation = false
        showingRoomJoining = false
        
        // Keep existing connection status if we're already connected
        if connectionStatus != .connected {
            connectionStatus = .disconnected
            roomCode = ""
            playerName = ""
        }
        
        // Clear subscriptions
        stopListening()
        cancellables.removeAll()
        
        checkFirebaseConnection()
    }
    
    // MARK: - Room Management
    func createRoom() {
        guard !playerName.isEmpty else {
            errorMessage = "Please enter your name"
            return
        }
        
        print("🏠 Creating room for player: \(playerName)")
        isLoading = true
        connectionStatus = .connecting
        errorMessage = nil
        
        firebaseService.createAnonymousUser()
            .flatMap { [weak self] userId -> AnyPublisher<String, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "MultiplayerGameState", code: 0, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                        .eraseToAnyPublisher()
                }
                
                let player = Player(id: userId, name: self.playerName)
                self.currentUser = player
                print("👤 Created user: \(userId)")
                
                return self.firebaseService.createGameRoom(hostId: userId, maxPlayers: 8)
            }
            .flatMap { [weak self] roomId -> AnyPublisher<String, Error> in
                guard let self = self, let user = self.currentUser else {
                    return Fail(error: NSError(domain: "MultiplayerGameState", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                        .eraseToAnyPublisher()
                }
                
                print("🏠 Created room: \(roomId)")
                
                return self.firebaseService.joinGameRoom(roomId: roomId, player: user)
                    .map { _ in roomId }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Create room failed: \(error)")
                        self?.errorMessage = "Failed to create room: \(error.localizedDescription)"
                        self?.connectionStatus = .disconnected
                    }
                },
                receiveValue: { [weak self] roomId in
                    print("✅ Room created successfully: \(roomId)")
                    self?.roomCode = roomId
                    self?.connectionStatus = .inRoom
                    self?.startListeningToRoom(roomId: roomId)
                }
            )
            .store(in: &cancellables)
    }

    func joinRoom() {
        guard !playerName.isEmpty, !roomCode.isEmpty else {
            errorMessage = "Please enter your name and room code"
            return
        }
        
        print("🚪 Joining room \(roomCode) as \(playerName)")
        isLoading = true
        connectionStatus = .connecting
        errorMessage = nil
        let currentRoomCode = roomCode
        
        firebaseService.createAnonymousUser()
            .flatMap { [weak self] userId -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "MultiplayerGameState", code: 0, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                        .eraseToAnyPublisher()
                }
                
                let player = Player(id: userId, name: self.playerName)
                self.currentUser = player
                print("👤 Created user for join: \(userId)")
                
                return self.firebaseService.joinGameRoom(roomId: currentRoomCode, player: player)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Join room failed: \(error)")
                        self?.errorMessage = "Failed to join room: \(error.localizedDescription)"
                        self?.connectionStatus = .disconnected
                    }
                },
                receiveValue: { [weak self] _ in
                    print("✅ Joined room successfully")
                    self?.connectionStatus = .inRoom
                    self?.startListeningToRoom(roomId: currentRoomCode)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Game Play Logic
    func playerClickedNumber(_ number: Int) {
        guard let userId = currentUser?.id,
              let roomId = gameRoom?.id else {
            print("❌ Cannot click number: missing game state")
            return
        }
        
        guard currentUser?.boardNumbers.contains(number) == true else {
            errorMessage = "This number (\(number)) is not on your board!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.errorMessage = nil
            }
            return
        }
        
        guard !playerMarkedNumbers.contains(number) else {
            print("⚠️ Number \(number) already marked")
            return
        }
        
        print("👤 Player clicked number: \(number)")
        
        playerMarkedNumbers.append(number)
        updatePlayerProgress()
        checkForBingo()
    }

    private func updatePlayerProgress() {
        guard let userId = currentUser?.id,
              let roomId = gameRoom?.id,
              let user = currentUser else {
            print("❌ Cannot update progress: missing user data")
            return
        }
        
        let winPositions = [
            [0,1,2,3,4], [5,6,7,8,9], [10,11,12,13,14], [15,16,17,18,19], [20,21,22,23,24],
            [0,5,10,15,20], [1,6,11,16,21], [2,7,12,17,22], [3,8,13,18,23], [4,9,14,19,24],
            [0,6,12,18,24], [4,8,12,16,20]
        ]
        
        var markedPositions: Set<Int> = []
        for (index, boardNumber) in user.boardNumbers.enumerated() {
            if playerMarkedNumbers.contains(boardNumber) {
                markedPositions.insert(index)
            }
        }
        
        var newCompletedLines: Set<Int> = []
        for (index, pattern) in winPositions.enumerated() {
            if Set(pattern).isSubset(of: markedPositions) {
                newCompletedLines.insert(index)
            }
        }
        
        print("📊 Player progress: \(newCompletedLines.count) completed lines")
        
        currentUser?.completedLines = Array(newCompletedLines)
        currentUser?.hasWon = newCompletedLines.count >= 5
        currentUser?.markedNumbers = playerMarkedNumbers
        
        firebaseService.updatePlayerProgress(
            roomId: roomId,
            playerId: userId,
            completedLines: newCompletedLines,
            markedNumbers: playerMarkedNumbers,
            hasWon: newCompletedLines.count >= 5
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ Failed to update progress: \(error)")
                }
            },
            receiveValue: { _ in
                print("✅ Progress updated successfully")
            }
        )
        .store(in: &cancellables)
    }

    private func checkForBingo() {
        guard let user = currentUser else { return }
        
        if user.completedLines.count >= 5 && !user.hasWon {
            print("🎉 Player has BINGO! Can claim victory")
        }
    }

    func toggleReady() {
        guard let userId = currentUser?.id,
              let roomId = roomCode.isEmpty ? nil : roomCode else {
            print("❌ Cannot toggle ready: missing IDs")
            return
        }
        
        let newReadyStatus = !(gameRoom?.players[userId]?.isReady ?? false)
        print("🔄 Toggling ready status to: \(newReadyStatus)")
        
        firebaseService.updatePlayerReady(roomId: roomId, playerId: userId, isReady: newReadyStatus)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to toggle ready: \(error)")
                        self?.errorMessage = "Failed to update ready status: \(error.localizedDescription)"
                    }
                },
                receiveValue: { _ in
                    print("✅ Ready status updated")
                }
            )
            .store(in: &cancellables)
    }

    func startMultiplayerGame() {
        guard let roomId = roomCode.isEmpty ? nil : roomCode,
              let room = gameRoom,
              room.canStartGame else {
            print("❌ Cannot start game: conditions not met")
            return
        }
        
        print("🎮 Starting multiplayer game")
        isLoading = true
        
        playerMarkedNumbers = []
        hasPlayerMarkedCurrentNumber = false
        shouldHighlightCurrentNumber = false
        
        firebaseService.startGame(roomId: roomId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Failed to start game: \(error)")
                        self?.errorMessage = "Failed to start game: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] _ in
                    print("✅ Game started successfully")
                    self?.connectionStatus = .playing
                }
            )
            .store(in: &cancellables)
    }

    func leaveRoom() {
        guard let userId = currentUser?.id,
              let roomId = roomCode.isEmpty ? nil : roomCode else {
            print("❌ Cannot leave room: missing IDs")
            return
        }
        
        print("🚪 Leaving room \(roomId)")
        
        firebaseService.leaveRoom(roomId: roomId, playerId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to leave room: \(error)")
                        self?.errorMessage = "Failed to leave room: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] _ in
                    print("✅ Left room successfully")
                    self?.initializeForNewSession()
                }
            )
            .store(in: &cancellables)
    }

    func claimBingo() {
        guard let userId = currentUser?.id,
              let roomId = gameRoom?.id else {
            print("❌ Cannot claim bingo: missing IDs")
            return
        }
        
        print("🏆 Claiming BINGO!")
        
        firebaseService.claimBingo(roomId: roomId, playerId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to claim BINGO: \(error)")
                        self?.errorMessage = "Failed to claim BINGO: \(error.localizedDescription)"
                    }
                },
                receiveValue: { _ in
                    print("✅ BINGO claimed successfully")
                }
            )
            .store(in: &cancellables)
    }

    private func startListeningToRoom(roomId: String) {
        print("👂 Starting to listen to room: \(roomId)")
        
        firebaseService.listenToGameRoom(roomId: roomId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gameRoom in
                guard let self = self else { return }
                
                self.gameRoom = gameRoom
                if gameRoom?.gameState == .playing {
                    self.connectionStatus = .playing
                } else if gameRoom?.gameState == .finished {
                    print("🏁 Game finished")
                } else if gameRoom != nil {
                    self.connectionStatus = .inRoom
                }
            }
            .store(in: &cancellables)
    }
    
    func startNewGame() {
        print("🔄 Starting new multiplayer game session")
        initializeForNewSession()
    }
    
    private func stopListening() {
        print("🛑 Stopping Firebase listeners")
        firebaseService.stopListening()
        roomListener?.cancel()
        roomListener = nil
        connectionCancellable?.cancel()
        connectionCancellable = nil
    }
    
    func endGame() {
        print("🛑 Ending multiplayer game")
        stopListening()
        initializeForNewSession()
    }
}
