//
//  BingoCell.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 05/08/25.
//

import SwiftUI

struct BingoCell: View {
    let number: Int
    let isMarked: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        let fillColor: Color = isMarked ? .gray : .black
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                Text("\(number)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .aspectRatio(1, contentMode: .fit) // Ensures square cells
            .shadow(color: .gray, radius: 10, x: 0, y: 10)
        }
        .disabled(isDisabled)
    }
}
