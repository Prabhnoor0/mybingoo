//
//  GameHeader.swift
//  MyBingo
//

import SwiftUI

struct GameHeader: View {
    @ObservedObject var gameModeManager: GameModeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(alignment: .center) {
            Button(action: returnToMainMenu) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.backward")
                    Text("Menu")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .buttonStyle(ScaledButtonStyle())

            Spacer()

            Text(gameModeManager.selectedMode.displayName)
                .font(.headline).fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.red, AppTheme.green, AppTheme.yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .padding([.horizontal, .top])
    }

    private func returnToMainMenu() {
        gameModeManager.returnToMainMenu()
        dismiss()
    }
}
