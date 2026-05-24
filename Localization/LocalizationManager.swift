//
//  LocalizationManager.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()

    private(set) var language: AppLanguage
    private var table: [String: [String: String]] = [:]

    private init() {
        let raw = UserDefaults.standard.string(forKey: AppLanguage.storageKey)
        language = AppLanguage(rawValue: raw ?? "") ?? .english
        loadStringTable()
    }

    func setLanguage(_ newLanguage: AppLanguage) {
        guard language != newLanguage else { return }
        language = newLanguage
        UserDefaults.standard.set(newLanguage.rawValue, forKey: AppLanguage.storageKey)
        SignCatalog.shared.reload(language: newLanguage)
        TheoryQuestionCatalog.shared.reload(language: newLanguage)
    }

    func text(_ key: StringKey) -> String {
        text(key.rawValue)
    }

    func text(_ key: String) -> String {
        table[language.rawValue]?[key] ?? table[AppLanguage.english.rawValue]?[key] ?? key
    }

    func text(_ key: StringKey, _ arguments: CVarArg...) -> String {
        let format = text(key)
        return String(format: format, locale: locale, arguments: Array(arguments))
    }

    var locale: Locale {
        switch language {
        case .english: Locale(identifier: "en")
        case .swedish: Locale(identifier: "sv")
        }
    }

    private func loadStringTable() {
        guard let url = Bundle.main.url(forResource: "strings", withExtension: "json") else {
            table = [:]
            return
        }
        do {
            let data = try Data(contentsOf: url)
            table = try JSONDecoder().decode([String: [String: String]].self, from: data)
        } catch {
            table = [:]
        }
    }
}

extension SignCategory {
    func titleKey() -> StringKey {
        switch self {
        case .warning: .categoryWarningTitle
        case .priority: .categoryPriorityTitle
        case .prohibition: .categoryProhibitionTitle
        case .mandatory: .categoryMandatoryTitle
        case .information: .categoryInformationTitle
        case .additional: .categoryAdditionalTitle
        }
    }

    func subtitleKey() -> StringKey {
        switch self {
        case .warning: .categoryWarningSubtitle
        case .priority: .categoryPrioritySubtitle
        case .prohibition: .categoryProhibitionSubtitle
        case .mandatory: .categoryMandatorySubtitle
        case .information: .categoryInformationSubtitle
        case .additional: .categoryAdditionalSubtitle
        }
    }

    func localizedTitle(using l10n: LocalizationManager) -> String {
        l10n.text(titleKey())
    }

    func localizedSubtitle(using l10n: LocalizationManager) -> String {
        l10n.text(subtitleKey())
    }
}
