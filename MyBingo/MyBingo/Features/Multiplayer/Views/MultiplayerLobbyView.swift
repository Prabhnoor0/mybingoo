//
//  MultiplayerLobbyView.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 05/08/25.
//

import SwiftUI

struct MultiplayerLobbyView: View {
    @ObservedObject var gameState: MultiplayerGameState

    var body: some View {
        // Add this button temporarily above "Create Room"
        

        VStack(spacing: 30) {
            Text("Multiplayer Bingo")
                .font(.largeTitle).fontWeight(.bold)
                .padding(.top, 20)

            // Connection Status
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Main Content Based on Connection Status
            Group {
                switch gameState.connectionStatus {
                case .disconnected:
                    VStack(spacing: 20) {
                        Button("Create Room") {
                            gameState.showingRoomCreation = true
                        }
                        .buttonStyle(GameModeButtonStyle(color: .blue))
                        
                        Button("Join Room") {
                            gameState.showingRoomJoining = true
                        }
                        .buttonStyle(GameModeButtonStyle(color: .green))
                    }
                    
                case .connecting:
                    ProgressView("Connecting...")
                        .padding()
                        
                case .connected:
                    ProgressView("Joining room...")
                        .padding()
                    
                case .inRoom:
                    RoomLobbyContent(gameState: gameState)
                    
                case .playing:
                    MultiplayerGameContent(gameState: gameState)
                }
            }

            Spacer()

            if let error = gameState.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .sheet(isPresented: $gameState.showingRoomCreation) {
            CreateRoomSheet(gameState: gameState)
        }
        .sheet(isPresented: $gameState.showingRoomJoining) {
            JoinRoomSheet(gameState: gameState)
        }
        .onAppear {
            print("👀 MultiplayerLobbyView appeared with status: \(gameState.connectionStatus)")
        }
    }
    
    private var statusColor: Color {
        switch gameState.connectionStatus {
        case .disconnected: return .red
        case .connecting: return .orange
        case .connected, .inRoom: return .green
        case .playing: return .blue
        }
    }
    
    private var statusText: String {
        switch gameState.connectionStatus {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .inRoom: return "In Room"
        case .playing: return "Playing"
        }
    }
}

private struct GameModeButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2).foregroundColor(.white)
            .frame(width: 200, height: 55)
            .background(color.opacity(configuration.isPressed ? 0.6 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct CreateRoomSheet: View {
    @ObservedObject var gameState: MultiplayerGameState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create New Room")
                    .font(.title).fontWeight(.bold)
                    .padding(.top, 20)
                
                TextField("Your Name", text: $gameState.playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Create Room") {
                    gameState.createRoom()
                    dismiss()
                }
                .font(.title2).foregroundColor(.white)
                .frame(width: 170, height: 55)
                .background(gameState.playerName.isEmpty ? Color.gray : Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(gameState.playerName.isEmpty || gameState.isLoading)
                
                if gameState.isLoading {
                    ProgressView("Creating room...")
                        .padding()
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct JoinRoomSheet: View {
    @ObservedObject var gameState: MultiplayerGameState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Join Room")
                    .font(.title).fontWeight(.bold)
                    .padding(.top, 20)
                
                TextField("Your Name", text: $gameState.playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Room Code", text: $gameState.roomCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Join Room") {
                    gameState.joinRoom()
                    dismiss()
                }
                .font(.title2).foregroundColor(.white)
                .frame(width: 170, height: 55)
                .background(canJoin ? Color.green : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(!canJoin || gameState.isLoading)
                
                if gameState.isLoading {
                    ProgressView("Joining room...")
                        .padding()
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private var canJoin: Bool {
        !gameState.playerName.isEmpty && !gameState.roomCode.isEmpty
    }
}

private struct RoomLobbyContent: View {
    @ObservedObject var gameState: MultiplayerGameState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Room Code")
                        .font(.headline).foregroundColor(.secondary)
                    
                    HStack {
                        Text(gameState.roomCode)
                            .font(.title).fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        
                        Button {
                            UIPasteboard.general.string = gameState.roomCode
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("Share this code with friends!")
                        .font(.caption).foregroundColor(.secondary)
                }
                .padding(.top)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Players")
                        Spacer()
                        Text("\(gameState.gameRoom?.players.count ?? 0)/\(gameState.gameRoom?.maxPlayers ?? 8)")
                    }
                    .font(.headline)
                    
                    Text("Game Status: \(gameState.gameRoom?.gameState.rawValue.capitalized ?? "Unknown")")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Players in Room")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 8) {
                        if let players = gameState.gameRoom?.players.values.sorted(by: { $0.joinedAt < $1.joinedAt }) {
                            ForEach(players, id: \.id) { player in
                                PlayerRow(
                                    player: player,
                                    isHost: player.id == gameState.gameRoom?.hostId,
                                    isCurrentUser: player.id == gameState.currentUser?.id
                                )
                            }
                        } else {
                            Text("No players found")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    if isHost {
                        Button(canStartGame ? "Start Game" : "Waiting for players...") {
                            gameState.startMultiplayerGame()
                        }
                        .font(.title2).foregroundColor(.white)
                        .frame(width: 200, height: 55)
                        .background(canStartGame ? Color.green : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .disabled(!canStartGame)
                    } else {
                        Button(isCurrentPlayerReady ? "Ready ✓" : "Mark as Ready") {
                            gameState.toggleReady()
                        }
                        .font(.title2).foregroundColor(.white)
                        .frame(width: 200, height: 55)
                        .background(isCurrentPlayerReady ? Color.green : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button("Leave Room") {
                        gameState.leaveRoom()
                    }
                    .font(.title2).foregroundColor(.white)
                    .frame(width: 200, height: 55)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private var isHost: Bool {
        gameState.currentUser?.id == gameState.gameRoom?.hostId
    }
    
    private var canStartGame: Bool {
        guard let room = gameState.gameRoom else { return false }
        return room.canStartGame && isHost
    }
    
    private var isCurrentPlayerReady: Bool {
        guard let userId = gameState.currentUser?.id,
              let room = gameState.gameRoom else { return false }
        return room.players[userId]?.isReady ?? false
    }
}

private struct PlayerRow: View {
    let player: Player
    let isHost: Bool
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(isCurrentUser ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Text(player.name.prefix(1).uppercased())
                    .font(.headline)
                    .foregroundColor(isCurrentUser ? .white : .primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(isCurrentUser ? .blue : .primary)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if isHost {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
                
                Text("Joined \(timeAgo(from: player.joinedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                if player.isReady {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Ready")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    HStack {
                        Image(systemName: "clock.circle.fill")
                            .foregroundColor(.orange)
                        Text("Not Ready")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "just now" }
        else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        }
    }
}

private struct MultiplayerGameContent: View {
    @ObservedObject var gameState: MultiplayerGameState
    @State private var showWinnerAlert = false
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 8) {
                Text("Multiplayer BINGO")
                    .font(.title2).fontWeight(.bold)
                
                HStack {
                    Text("Room: \(gameState.roomCode)")
                        .font(.subheadline).foregroundColor(.secondary)
                    Spacer()
                    Text("Players: \(gameState.gameRoom?.players.count ?? 0)")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top)
            
            VStack(spacing: 8) {
                Text("Click numbers on your board!")
                    .font(.headline).fontWeight(.semibold)
                    .foregroundColor(.green)
                
                if let lastMarked = gameState.playerMarkedNumbers.last {
                    Text("Last marked: \(lastMarked)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .frame(height: 60)
            
            if let currentUser = gameState.currentUser {
                VStack(spacing: 10) {
                    Text("Your Board")
                        .font(.headline).fontWeight(.bold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                        ForEach(0..<25, id: \.self) { index in
                            let number = currentUser.boardNumbers[index]
                            let isMarked = gameState.playerMarkedNumbers.contains(number)
                            
                            Button(action: {
                                if !isMarked {
                                    gameState.playerClickedNumber(number)
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isMarked ? Color.green : Color.blue)
                                        .opacity(isMarked ? 0.8 : 1.0)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                    
                                    Text("\(number)")
                                        .font(.title2).fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    if isMarked {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                            .offset(x: 15, y: -15)
                                    }
                                }
                                .aspectRatio(1, contentMode: .fit)
                            }
                            .disabled(isMarked)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            if let currentUser = gameState.currentUser {
                VStack(spacing: 5) {
                    Text("Lines Completed: \(currentUser.completedLines.count)/5")
                        .font(.subheadline).fontWeight(.semibold)
                    
                    ProgressView(value: Double(currentUser.completedLines.count), total: 5.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .frame(height: 8)
                        .padding(.horizontal, 40)
                }
            }
            
            if canClaimBingo {
                Button("🎉 BINGO! 🎉") {
                    gameState.claimBingo()
                }
                .font(.title).fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 200, height: 60)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
                .scaleEffect(1.1)
            }
            
            if let players = gameState.gameRoom?.players.values.filter({ $0.id != gameState.currentUser?.id }) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(players.sorted(by: { $0.name < $1.name }), id: \.id) { player in
                            VStack(spacing: 4) {
                                Text(player.name)
                                    .font(.caption).fontWeight(.semibold)
                                    .lineLimit(1)
                                
                                Text("\(player.completedLines.count)/5")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Circle()
                                    .fill(player.hasWon ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Text(player.hasWon ? "🏆" : "\(player.completedLines.count)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                    )
                            }
                            .frame(width: 60)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Button("Leave Game") {
                gameState.leaveRoom()
            }
            .font(.subheadline)
            .foregroundColor(.red)
            .padding(.top)
            
            Spacer()
        }
        .alert("Game Over!", isPresented: $showWinnerAlert) {
            Button("Back to Lobby") {
                gameState.endGame()
            }
        } message: {
            if let winnerId = gameState.gameRoom?.gameWinner,
               let winnerName = gameState.gameRoom?.players[winnerId]?.name {
                Text("🎉 \(winnerName) wins!")
            } else {
                Text("Game finished")
            }
        }
        .onChange(of: gameState.gameRoom?.gameWinner) { _, newValue in
            showWinnerAlert = newValue != nil
        }
    }
    
    private var canClaimBingo: Bool {
        guard let currentUser = gameState.currentUser else { return false }
        return currentUser.completedLines.count >= 5 && !currentUser.hasWon
    }
}
