//
//  BingoCell.swift
//  MyBingo
//

import SwiftUI

struct BingoCell: View {
    let number: Int
    let isMarked: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        let baseColor: Color = isMarked ? AppTheme.accent : AppTheme.neutral
        Button(action: {
            HapticsManager.shared.tap()
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(baseColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.secondary, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)

                Text("\(number)")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.white)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(ScaledButtonStyle())
        .disabled(isDisabled)
    }
}
