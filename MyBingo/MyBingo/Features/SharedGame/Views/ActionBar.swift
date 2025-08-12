//
//  ActionBar.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 05/08/25.
//
import SwiftUI

struct ActionBar: View {
    @ObservedObject var gameState: AIGameState  // Make it @ObservedObject
    let onNewGame: () -> Void
    let onEndGame: (() -> Void)?
    
    init(gameState: AIGameState, onNewGame: @escaping () -> Void, onEndGame: (() -> Void)? = nil) {
        self.gameState = gameState
        self.onNewGame = onNewGame
        self.onEndGame = onEndGame
    }
    
    var body: some View {
        VStack(spacing: 10) {
            
            if gameState.gameEnded {
                // Show "New Game" when game is over
                Button("New Game") {
                    onNewGame()
                }
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 170, height: 55)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                // Show "End Game" during gameplay
                Button("End Game") {
                    onEndGame?()
                }
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 170, height: 55)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.bottom, 20)
    }
}
