//
//  AppTheme.swift
//  MyBingo
//

import SwiftUI

struct AppTheme {
    // Core palette (red, green, yellow) and deep blue background
    static let red = Color(hex: "#EF4444")
    static let green = Color(hex: "#10B981")
    static let yellow = Color(hex: "#FFB703")
    static let deepBlue = Color(hex: "#0B1B3B") // page background

    // Aliases used by components
    static let primary = yellow
    static let secondary = green
    static let accent = red
    static let neutral = deepBlue
}

// MARK: - Utilities

extension Color {
    init(hex: String) {
        let r, g, b, a: CGFloat

        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexColor.hasPrefix("#") { hexColor.removeFirst() }

        if hexColor.count == 6 { hexColor.append("FF") }

        if hexColor.count == 8, let hexNumber = UInt64(hexColor, radix: 16) {
            r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x0000_00FF) / 255
            self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
            return
        }

        self = .clear
    }
}

// Note: Background animations removed per design update

// MARK: - Reusable Button Styles

struct GlowingPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2).fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 55)
            .background(AppTheme.primary)
            .cornerRadius(16)
            .shadow(color: AppTheme.accent.opacity(configuration.isPressed ? 0.2 : 0.6), radius: configuration.isPressed ? 6 : 16, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct OutlineSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2).fontWeight(.semibold)
            .foregroundColor(AppTheme.secondary)
            .frame(maxWidth: .infinity, minHeight: 55)
            .background(AppTheme.secondary.opacity(0.12))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.secondary, lineWidth: 2))
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct RedAccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2).fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 55)
            .background(AppTheme.accent)
            .cornerRadius(16)
            .shadow(color: AppTheme.accent.opacity(configuration.isPressed ? 0.3 : 0.6), radius: configuration.isPressed ? 8 : 20, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SquareButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
            .cornerRadius(20)
            .shadow(color: backgroundColor.opacity(configuration.isPressed ? 0.3 : 0.6), radius: configuration.isPressed ? 8 : 20, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Button press scale for any Button

struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}


