//
//  ModeSelectionView.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 04/08/25.
//


import SwiftUI

struct ModeSelectionView: View {
    @StateObject private var gameModeManager = GameModeManager()
    @State private var showGameView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {

                Text("MyBingo")
                    .font(.largeTitle).fontWeight(.bold)
                    .padding(.top, 50)

                VStack(spacing: 20) {
                    // Single-player button
                    Button("vs AI") {
                        gameModeManager.startGame(mode: .singlePlayerAI)
                        showGameView = true
                    }
                    .buttonStyle(GameModeButtonStyle(color: .blue))

                    // Multiplayer button
                    Button("Multiplayer") {
                        gameModeManager.startGame(mode: .multiplayer)
                        showGameView = true
                    }
                    .buttonStyle(GameModeButtonStyle(color: .green))
                }

                Spacer()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(isPresented: $showGameView) {
            GameView(gameModeManager: gameModeManager)
        }
    }
}

// Re-usable style
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
