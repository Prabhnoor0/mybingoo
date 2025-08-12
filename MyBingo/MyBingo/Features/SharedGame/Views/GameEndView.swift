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
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 30) {
                Text(gameState.gameWinner ?? "Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("Final Results")
                    .font(.title2)
                    .fontWeight(.semibold)
                
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
                    .background(Color.gray)
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
                VStack(spacing: 16) {
                    Button(action: onNewGame) {
                        Text("New Game")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                   /* Button(action: onSeeResults) {
                        Text("See Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }*/
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
