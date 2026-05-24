//
//  SignCategory.swift
//  Trafikal
//

import SwiftUI

enum SignCategory: String, Codable, CaseIterable, Identifiable {
    case warning
    case priority
    case prohibition
    case mandatory
    case information
    case additional

    var id: String { rawValue }

    @MainActor
    var title: String {
        localizedTitle(using: LocalizationManager.shared)
    }

    @MainActor
    var subtitle: String {
        localizedSubtitle(using: LocalizationManager.shared)
    }

    var systemImage: String {
        switch self {
        case .warning: "exclamationmark.triangle.fill"
        case .priority: "arrow.triangle.merge"
        case .prohibition: "nosign"
        case .mandatory: "arrow.turn.up.right"
        case .information: "signpost.right.fill"
        case .additional: "rectangle.bottomthird.inset.filled"
        }
    }

    var accentColor: Color {
        switch self {
        case .warning: Color(red: 0.95, green: 0.75, blue: 0.1)
        case .priority: Color(red: 0.95, green: 0.2, blue: 0.15)
        case .prohibition: Color(red: 0.9, green: 0.15, blue: 0.2)
        case .mandatory: Color(red: 0.15, green: 0.35, blue: 0.85)
        case .information: Color(red: 0.1, green: 0.55, blue: 0.35)
        case .additional: Color(red: 0.35, green: 0.35, blue: 0.4)
        }
    }
}
