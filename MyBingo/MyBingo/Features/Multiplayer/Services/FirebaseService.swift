//
//  FirebaseService.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 05/08/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Combine

final class FirebaseService: ObservableObject {
    private let database = Database.database().reference()
    private var gameRoomListener: DatabaseHandle?
    private var connectionListener: DatabaseHandle?
    
    init() {
        if FirebaseApp.app() == nil {
            print("⚠️ Warning: Firebase not configured properly in FirebaseService")
        } else {
            print("✅ FirebaseService initialized successfully")
        }
    }
    
    deinit {
        stopListening()
    }
    
    // MARK: - User Management
    func createAnonymousUser() -> AnyPublisher<String, Error> {
        return Future { promise in
            print("👤 Creating anonymous user...")
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("❌ Anonymous auth failed: \(error)")
                    promise(.failure(error))
                } else if let user = result?.user {
                    print("✅ Anonymous user created: \(user.uid)")
                    promise(.success(user.uid))
                } else {
                    let customError = NSError(domain: "FirebaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
                    promise(.failure(customError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Game Room Management
    func createGameRoom(hostId: String, maxPlayers: Int = 8) -> AnyPublisher<String, Error> {
        return Future { promise in
            let gameRoom = GameRoom(hostId: hostId, maxPlayers: maxPlayers)
            
            do {
                let data = try JSONEncoder().encode(gameRoom)
                let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                
                print("🏠 Creating room with ID: \(gameRoom.id)")
                
                // Inside createGameRoom’s completion closure:
                self.database.child("gameRooms").child(gameRoom.id).setValue(dict) { error, _ in
                    if let error = error {
                        // Print full error details
                        print("❌ Firebase setValue failed:")
                        dump(error)  // prints all error info
                        promise(.failure(error))
                    } else {
                        promise(.success(gameRoom.id))
                    }
                }

            } catch {
                print("❌ Failed to encode game room: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func joinGameRoom(roomId: String, player: Player) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let playerRef = self.database.child("gameRooms").child(roomId).child("players").child(player.id)
            
            do {
                let data = try JSONEncoder().encode(player)
                let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                
                print("👤 Adding player \(player.name) to room \(roomId)")
                
                playerRef.setValue(dict) { error, _ in
                    if let error = error {
                        print("❌ Failed to join room: \(error)")
                        promise(.failure(error))
                    } else {
                        print("✅ Player joined room successfully")
                        promise(.success(()))
                    }
                }
            } catch {
                print("❌ Failed to encode player: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func listenToGameRoom(roomId: String) -> AnyPublisher<GameRoom?, Never> {
        print("👂 Setting up listener for room: \(roomId)")
        let subject = PassthroughSubject<GameRoom?, Never>()

        let roomRef = database.child("gameRooms").child(roomId)
        var handle: DatabaseHandle?
        handle = roomRef.observe(.value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                print("⚠️ No data found for room: \(roomId)")
                subject.send(nil)
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let gameRoom = try JSONDecoder().decode(GameRoom.self, from: jsonData)
                print("📡 Room data received: \(gameRoom.players.count) players")
                subject.send(gameRoom)
            } catch {
                print("❌ Error decoding game room: \(error)")
                subject.send(nil)
            }
        }

        // keep a reference for external stopListening
        self.gameRoomListener = handle

        return subject
            .handleEvents(receiveCancel: { [weak self] in
                if let handle = handle {
                    roomRef.removeObserver(withHandle: handle)
                    if self?.gameRoomListener == handle {
                        self?.gameRoomListener = nil
                    }
                    print("🛑 Cancelled room listener for \(roomId)")
                }
            })
            .eraseToAnyPublisher()
    }
    
    func stopListening() {
        if let listener = gameRoomListener {
            database.removeObserver(withHandle: listener)
            gameRoomListener = nil
            print("🛑 Stopped Firebase listener")
        }
        if let connectionListener = connectionListener {
            Database.database().reference(withPath: ".info/connected").removeObserver(withHandle: connectionListener)
            self.connectionListener = nil
            print("🛑 Stopped connection listener")
        }
    }
    
    func updatePlayerReady(roomId: String, playerId: String, isReady: Bool) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("🔄 Updating ready status for \(playerId): \(isReady)")
            
            self.database.child("gameRooms").child(roomId).child("players").child(playerId).child("isReady").setValue(isReady) { error, _ in
                if let error = error {
                    print("❌ Failed to update ready status: \(error)")
                    promise(.failure(error))
                } else {
                    print("✅ Ready status updated")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func startGame(roomId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let updates: [String: Any] = [
                "gameState": GameRoom.GameState.playing.rawValue,
                "calledNumbers": [],
                "currentNumber": NSNull()
            ]
            
            print("🎮 Starting game in room: \(roomId)")
            
            self.database.child("gameRooms").child(roomId).updateChildValues(updates) { error, _ in
                if let error = error {
                    print("❌ Failed to start game: \(error)")
                    promise(.failure(error))
                } else {
                    print("✅ Game started successfully")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func leaveRoom(roomId: String, playerId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("🚪 Removing player \(playerId) from room \(roomId)")
            
            self.database.child("gameRooms").child(roomId).child("players").child(playerId).removeValue { error, _ in
                if let error = error {
                    print("❌ Failed to leave room: \(error)")
                    promise(.failure(error))
                } else {
                    print("✅ Player left room successfully")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func claimBingo(roomId: String, playerId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("🏆 Processing BINGO claim for player: \(playerId)")
            
            self.database.child("gameRooms").child(roomId).child("players").child(playerId).observeSingleEvent(of: .value) { snapshot in
                guard let playerData = snapshot.value as? [String: Any],
                      let playerName = playerData["name"] as? String else {
                    let error = NSError(domain: "FirebaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get player data"])
                    promise(.failure(error))
                    return
                }
                
                let updates: [String: Any] = [
                    "gameState": GameRoom.GameState.finished.rawValue,
                    "gameWinner": playerId,
                    "players/\(playerId)/hasWon": true
                ]
                
                print("🏆 Setting winner: \(playerName)")
                
                self.database.child("gameRooms").child(roomId).updateChildValues(updates) { error, _ in
                    if let error = error {
                        print("❌ Failed to claim BINGO: \(error)")
                        promise(.failure(error))
                    } else {
                        print("✅ BINGO claimed successfully")
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func updatePlayerProgress(roomId: String, playerId: String, completedLines: Set<Int>, markedNumbers: [Int], hasWon: Bool) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let updates: [String: Any] = [
                "players/\(playerId)/completedLines": Array(completedLines),
                "players/\(playerId)/markedNumbers": markedNumbers,
                "players/\(playerId)/hasWon": hasWon
            ]
            
            self.database.child("gameRooms").child(roomId).updateChildValues(updates) { error, _ in
                if let error = error {
                    print("❌ Failed to update progress: \(error)")
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Connection Monitoring
    func listenToConnection() -> AnyPublisher<Bool, Never> {
        let subject = PassthroughSubject<Bool, Never>()
        let infoRef = Database.database().reference(withPath: ".info/connected")
        var handle: DatabaseHandle?
        handle = infoRef.observe(.value) { snapshot in
            if let connected = snapshot.value as? Bool {
                print("📶 Firebase .info/connected = \(connected)")
                subject.send(connected)
            } else {
                subject.send(false)
            }
        }
        // Keep a reference so we can stop it on service deinit/stop
        self.connectionListener = handle

        return subject
            .handleEvents(receiveCancel: {
                if let handle = handle {
                    infoRef.removeObserver(withHandle: handle)
                    print("🛑 Cancelled connection listener")
                }
            })
            .eraseToAnyPublisher()
    }
}
