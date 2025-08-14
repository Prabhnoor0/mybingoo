//
//  PlayerInfoPanel.swift
//  MyBingo
//


import SwiftUI

struct PlayerInfoPanel: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(8)
    }
}
