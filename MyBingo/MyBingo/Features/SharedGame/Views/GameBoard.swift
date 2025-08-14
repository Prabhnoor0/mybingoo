//
//  GameBoard.swift
//  MyBingo
//


import SwiftUI

struct GameBoard: View {
    let numbers: [Int]
    let markedNumbers: Set<Int>
    let isDisabled: Bool
    let onCellTap: (Int) -> Void
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<25, id: \.self) { idx in
                BingoCell(
                    number: numbers[idx],
                    isMarked: markedNumbers.contains(numbers[idx]),
                    isDisabled: isDisabled
                ) {
                    onCellTap(numbers[idx])
                }
            }
        }
        .padding()
        .frame(maxWidth: 320, maxHeight: 320)
    }
}
