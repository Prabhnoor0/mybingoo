//
//  BingoBoard.swift
//  MyBingo
//


import SwiftUI

struct BingoBoard: View {
    let title: String
    let boardNumbers: [Int]
    let markedNumbers: Set<Int>
    let completedLines: Set<Int>
    let isDisabled: Bool
    let onNumberTapped: ((Int) -> Void)?
    
    private let bingoLetters = ["B", "I", "N", "G", "O"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 5)
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            VStack(spacing: 2) {
                // B-I-N-G-O Headers - Turn gray based on number of completed lines
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { letterIndex in
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 48, height: 35)
                            .overlay(
                                Text(bingoLetters[letterIndex])
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(shouldLetterBeGray(letterIndex) ? .gray : AppTheme.secondary)
                                    .animation(.easeInOut(duration: 0.3), value: completedLines.count)
                            )
                    }
                }
                
                // Game Board with Line Overlays
                ZStack {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(0..<25, id: \.self) { index in
                            let number = boardNumbers[index]
                            BingoCell(
                                number: number,
                                isMarked: markedNumbers.contains(number),
                                isDisabled: isDisabled || markedNumbers.contains(number)
                            ) {
                                onNumberTapped?(number)
                            }
                        }
                    }
                    
                  
                    ForEach(Array(completedLines), id: \.self) { lineIndex in
                        LineOverlay(lineIndex: lineIndex)
                            .animation(.easeInOut(duration: 0.5), value: completedLines)
                    }
                }
                .frame(width: 260, height: 260)
            }
        }
        .padding(.vertical, 10)
    }
    
    private func shouldLetterBeGray(_ letterIndex: Int) -> Bool {
        return completedLines.count > letterIndex
    }
}

struct LineOverlay: View {
    let lineIndex: Int
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let cellWidth = width / 5
                let cellHeight = height / 5
                
                switch lineIndex {
                // Horizontal lines (rows)
                case 0: // Row 0
                    path.move(to: CGPoint(x: 0, y: cellHeight * 0.5))
                    path.addLine(to: CGPoint(x: width, y: cellHeight * 0.5))
                case 1: // Row 1
                    path.move(to: CGPoint(x: 0, y: cellHeight * 1.5))
                    path.addLine(to: CGPoint(x: width, y: cellHeight * 1.5))
                case 2: // Row 2
                    path.move(to: CGPoint(x: 0, y: cellHeight * 2.5))
                    path.addLine(to: CGPoint(x: width, y: cellHeight * 2.5))
                case 3: // Row 3
                    path.move(to: CGPoint(x: 0, y: cellHeight * 3.5))
                    path.addLine(to: CGPoint(x: width, y: cellHeight * 3.5))
                case 4: // Row 4
                    path.move(to: CGPoint(x: 0, y: cellHeight * 4.5))
                    path.addLine(to: CGPoint(x: width, y: cellHeight * 4.5))
                
                // Vertical lines (columns)
                case 5: // Column 0 (B)
                    path.move(to: CGPoint(x: cellWidth * 0.5, y: 0))
                    path.addLine(to: CGPoint(x: cellWidth * 0.5, y: height))
                case 6: // Column 1 (I)
                    path.move(to: CGPoint(x: cellWidth * 1.5, y: 0))
                    path.addLine(to: CGPoint(x: cellWidth * 1.5, y: height))
                case 7: // Column 2 (N)
                    path.move(to: CGPoint(x: cellWidth * 2.5, y: 0))
                    path.addLine(to: CGPoint(x: cellWidth * 2.5, y: height))
                case 8: // Column 3 (G)
                    path.move(to: CGPoint(x: cellWidth * 3.5, y: 0))
                    path.addLine(to: CGPoint(x: cellWidth * 3.5, y: height))
                case 9: // Column 4 (O)
                    path.move(to: CGPoint(x: cellWidth * 4.5, y: 0))
                    path.addLine(to: CGPoint(x: cellWidth * 4.5, y: height))
                
                // Diagonal lines
                case 10: // Main diagonal
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: height))
                case 11: // Anti-diagonal
                    path.move(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    
                default:
                    break
                }
            }
            .stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
    }
}
