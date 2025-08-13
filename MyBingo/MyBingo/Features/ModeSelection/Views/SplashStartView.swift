//
//  SplashStartView.swift
//  MyBingo
//

import SwiftUI

struct SplashStartView: View {
    @State private var showModes = false

    var body: some View {
        ZStack {
            AppTheme.neutral
                .ignoresSafeArea()

            if showModes {
                ModeSelectionView()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                VStack(spacing: 32) {
                    // Main "My Bingo" title with vibrant colors - no animation
                    VStack(spacing: 8) {
                        Text("My")
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.red, AppTheme.green, AppTheme.yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Text("BINGO")
                            .font(.system(size: 72, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.red, AppTheme.green, AppTheme.yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // Tap to start text with better contrast
                    Text("Tap to start")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.red.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(AppTheme.red, lineWidth: 2)
                                )
                        )
                }
                .contentShape(Rectangle())
                .onTapGesture { 
                    withAnimation(.easeInOut(duration: 0.35)) { 
                        showModes = true 
                    } 
                }
            }
        }
    }
}


