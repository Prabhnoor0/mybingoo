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
        VStack(spacing: 12) {
            if gameState.gameEnded {
                Button {
                    onNewGame()
                } label: {
                    Text("New Game")
                        .frame(width: 200)
                }
                .buttonStyle(GlowingPrimaryButtonStyle())
            } else {
                Button {
                    onEndGame?()
                } label: {
                    Text("End Game")
                        .frame(width: 200)
                }
                .buttonStyle(RedAccentButtonStyle())
            }
        }
        .padding(.bottom, 20)
    }
}
