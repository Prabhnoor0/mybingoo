//
//  GameHeader.swift
//  MyBingo
//

import SwiftUI

struct GameHeader: View {
    @ObservedObject var gameModeManager: GameModeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button(action: returnToMainMenu) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.backward")
                    Text("Menu")
                }
            }
            .font(.subheadline).foregroundColor(.blue)

            Spacer()

            Text(gameModeManager.selectedMode.displayName)
                .font(.headline).fontWeight(.bold)
        }
        .padding([.horizontal, .top])
    }

    private func returnToMainMenu() {
        gameModeManager.returnToMainMenu()
        dismiss()
    }
}
