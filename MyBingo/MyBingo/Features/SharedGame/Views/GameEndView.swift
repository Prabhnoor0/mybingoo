//
//  GameEndView.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 05/08/25.
//

import SwiftUI

struct GameEndView: View {
    let gameState: AIGameState
    let onNewGame: () -> Void
    let onSeeResults: () -> Void
    
    var body: some View {
        ZStack {
            AppTheme.neutral
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 30) {
                    Text(gameState.gameWinner ?? "Game Over")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.red, AppTheme.green, AppTheme.yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        .transition(.scale.combined(with: .opacity))

                    Text("Final Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Player's Board
                    BingoBoard(
                        title: "Your Board",
                        boardNumbers: gameState.playerBoardNumbers,
                        markedNumbers: gameState.markedNumbers,
                        completedLines: gameState.playerCompletedLines,
                        isDisabled: true,
                        onNumberTapped: nil
                    )
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.white.opacity(0.35))
                        .padding(.horizontal, 40)
                    
                    // AI's Board
                    BingoBoard(
                        title: "AI's Board",
                        boardNumbers: gameState.aiBoardNumbers,
                        markedNumbers: gameState.markedNumbers,
                        completedLines: gameState.aiCompletedLines,
                        isDisabled: true,
                        onNumberTapped: nil
                    )
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 14) {
                        Button(action: onNewGame) {
                            Text("Play Again")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GlowingPrimaryButtonStyle())

                        Button(action: onSeeResults) {
                            Text("See Results")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(OutlineSecondaryButtonStyle())
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 10)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
