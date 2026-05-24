//
//  AppLanguage.swift
//  Trafikal
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case swedish = "sv"

    var id: String { rawValue }

    static let storageKey = "trafikal.appLanguage"

    var flagEmoji: String {
        switch self {
        case .english: "🇬🇧"
        case .swedish: "🇸🇪"
        }
    }

    /// Display name shown in the language picker (always in that language).
    var nativeDisplayName: String {
        switch self {
        case .english: "English"
        case .swedish: "Svenska"
        }
    }

    var pickerLabel: String {
        "\(flagEmoji) \(nativeDisplayName)"
    }
}
