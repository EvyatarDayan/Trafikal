//
//  SignCatalog.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class SignCatalog {
    static let shared = SignCatalog()

    private(set) var signs: [Sign] = []
    private(set) var loadError: String?
    private(set) var language: AppLanguage = .english

    private init() {
        let raw = UserDefaults.standard.string(forKey: AppLanguage.storageKey)
        language = AppLanguage(rawValue: raw ?? "") ?? .english
        load()
    }

    func reload(language: AppLanguage) {
        self.language = language
        load()
    }

    func load() {
        let resource = language == .swedish ? "signs-sv" : "signs"
        let fallback = language == .swedish ? "signs" : nil

        guard let url = bundleURL(resource: resource, fallback: fallback) else {
            loadError = LocalizationManager.shared.text(.errorSignsMissing)
            signs = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let bundle = try JSONDecoder().decode(SignsBundle.self, from: data)
            signs = bundle.signs.sorted { $0.code < $1.code }
            loadError = nil
        } catch {
            loadError = LocalizationManager.shared.text(.errorSignsLoad, error.localizedDescription)
            signs = []
        }
    }

    private func bundleURL(resource: String, fallback: String?) -> URL? {
        if let url = Bundle.main.url(forResource: resource, withExtension: "json") {
            return url
        }
        if let fallback, let url = Bundle.main.url(forResource: fallback, withExtension: "json") {
            return url
        }
        return nil
    }

    func signs(in category: SignCategory) -> [Sign] {
        signs.filter { $0.category == category }
    }

    func sign(code: String) -> Sign? {
        signs.first { $0.code == code }
    }

    func count(for category: SignCategory) -> Int {
        signs(in: category).count
    }

    var shuffledForQuiz: [Sign] {
        signs.shuffled()
    }

    /// Same sign all day for every user (deterministic from date + catalog).
    func signOfToday(on date: Date = Date(), calendar: Calendar = .current) -> Sign? {
        guard !signs.isEmpty else { return nil }
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = calendar.component(.year, from: date)
        let index = (year * 366 + day) % signs.count
        return signs[index]
    }
}
