//
//  HapticsManager.swift
//  MyBingo
//

import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notify = UINotificationFeedbackGenerator()

    func tap() {
        impactLight.impactOccurred()
    }

    func select() {
        impactMedium.impactOccurred()
    }

    func success() {
        notify.notificationOccurred(.success)
    }
}


