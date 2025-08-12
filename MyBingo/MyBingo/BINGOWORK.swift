//
//  BINGOWORK.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 25/06/25.
//

import SwiftUI

struct BINGOWORK: View {
    let number: Int
    let isDisabled: Bool
    let action: () -> Void
   
    
    var body: some View {
        let fillColor: Color = isDisabled ? .gray : .black
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
            .aspectRatio(1, contentMode: .fit)
            .shadow(color: .gray, radius: 10, x: 0, y: 10)
        }
        .disabled(isDisabled)
    }
}


#Preview {
    BINGOWORK(
        number: 7,
               isDisabled: false,
               action: {
                   print("Button tapped")
               }
    )
}
