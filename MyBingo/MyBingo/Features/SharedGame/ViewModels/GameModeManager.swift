//
//  GameModeManager.swift
//  MyBingo
//


import SwiftUI

final class GameModeManager: ObservableObject {
    @Published var selectedMode: GameMode = .singlePlayerAI
    @Published var aiGameState = AIGameState()
    @Published var multiplayerGameState = MultiplayerGameState()
    @Published var shouldReturnToMenu = false

    enum GameMode: String, CaseIterable {
        case singlePlayerAI = "singlePlayerAI"
        case multiplayer = "multiplayer"
        
        var displayName: String {
            switch self {
            case .singlePlayerAI: return "vs AI"
            case .multiplayer: return "Multiplayer"
            }
        }
    }

    func startGame(mode: GameMode) {
        print("🎮 Starting game mode: \(mode.displayName)")
        selectedMode = mode
        shouldReturnToMenu = false

        switch mode {
        case .singlePlayerAI:
            aiGameState.startNewGame()
        case .multiplayer:
            // Initialize multiplayer but don't reset connection
            multiplayerGameState.initializeForNewSession()
        }
    }

    func returnToMainMenu() {
        print("🏠 Returning to main menu")
        // Clean up current game state
        switch selectedMode {
        case .singlePlayerAI:
            aiGameState.endGame()
        case .multiplayer:
            multiplayerGameState.endGame()
        }
        
        shouldReturnToMenu = true
    }
}
