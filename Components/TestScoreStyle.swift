//
//  TestScoreStyle.swift
//  Trafikal
//

import SwiftUI

enum TestScoreStyle {
    /// 0-30% red, 31-70% orange, 71-100% green.
    static func foregroundStyle(for percent: Int) -> Color {
        let clamped = min(max(percent, 0), 100)
        switch clamped {
        case 0...30:
            return .red
        case 31...70:
            return .orange
        default:
            return .green
        }
    }

    static func badgeBackground(for percent: Int) -> Color {
        foregroundStyle(for: percent).opacity(0.15)
    }

    /// Green at 80%+ (simulation pass mark), red below.
    static func simulationForegroundStyle(for percent: Int) -> Color {
        percent >= SimulationSessionStore.passMarkPercent ? .green : Color.red.opacity(0.85)
    }

    static func simulationBadgeBackground(for percent: Int) -> Color {
        simulationForegroundStyle(for: percent).opacity(0.15)
    }
}
