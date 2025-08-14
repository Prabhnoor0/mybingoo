//
//  ModeSelectionView.swift
//  MyBingo
//


import SwiftUI

struct ModeSelectionView: View {
    @StateObject private var gameModeManager = GameModeManager()
    @State private var showGameView = false
    @State private var pulse = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.neutral
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                   
                    Text("My Bingo")
                        .font(.system(size: 54, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.red, AppTheme.green, AppTheme.yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 6)
                        .padding(.top, 60)
                        .scaleEffect(pulse ? 1.03 : 1.0)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)

                    Spacer()

                    // Square buttons side by side
                    HStack(spacing: 30) {
                        // Single-player button (Green) - Square
                        Button {
                            gameModeManager.startGame(mode: .singlePlayerAI)
                            showGameView = true
                        } label: {
                            VStack(spacing: 16) {
                                Image(systemName: "cpu")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                Text("vs AI")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(SquareButtonStyle(backgroundColor: AppTheme.green))
                        .frame(width: 140, height: 140)

                        // Multiplayer button (Red) - Square
                        Button {
                            gameModeManager.startGame(mode: .multiplayer)
                            showGameView = true
                        } label: {
                            VStack(spacing: 16) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                Text("Multiplayer")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(SquareButtonStyle(backgroundColor: AppTheme.red))
                        .frame(width: 140, height: 140)
                    }

                    Spacer()

                    Text("Choose your game mode")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 36)
                        .opacity(pulse ? 1 : 0.65)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                }
                .navigationBarHidden(true)
                .onAppear { pulse = true }
            }
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(isPresented: $showGameView) {
            GameView(gameModeManager: gameModeManager)
        }
    }
}


