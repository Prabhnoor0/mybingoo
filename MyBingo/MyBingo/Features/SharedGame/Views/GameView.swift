//
//  GameView.swift
//  MyBingo
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameModeManager: GameModeManager
    @State private var showEndGameAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.neutral
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    GameHeader(gameModeManager: gameModeManager)

                    Spacer(minLength: 10)

                    if gameModeManager.selectedMode == .singlePlayerAI {
                        AIGameContent(gameState: gameModeManager.aiGameState)
                    } else {
                        MultiplayerLobbyView(gameState: gameModeManager.multiplayerGameState)
                    }

                    Spacer(minLength: 10)

                    // Only show ActionBar for single-player and when not showing game end
                    if gameModeManager.selectedMode == .singlePlayerAI && gameModeManager.aiGameState.gameWinner == nil {
                        ActionBar(
                            gameState: gameModeManager.aiGameState,
                            onNewGame: { gameModeManager.startGame(mode: .singlePlayerAI) },
                            onEndGame: { showEndGameAlert = true }
                        )
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .navigationViewStyle(.stack)

        // Alerts
        .alert("End Game?", isPresented: $showEndGameAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Game", role: .destructive) {
                gameModeManager.returnToMainMenu()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to end the current game?")
        }
        // Watchers
        .onChange(of: gameModeManager.shouldReturnToMenu) { _, should in
            if should { dismiss() }
        }
    }
}
