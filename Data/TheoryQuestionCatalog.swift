//
//  TheoryQuestionCatalog.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class TheoryQuestionCatalog {
    static let shared = TheoryQuestionCatalog()

    private(set) var questions: [TheoryQuestion] = []
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
        let resource = language == .swedish ? "theory-questions-sv" : "theory-questions"
        let fallback = language == .swedish ? "theory-questions" : nil

        guard let url = bundleURL(resource: resource, fallback: fallback) else {
            loadError = LocalizationManager.shared.text(.errorTheoryMissing)
            questions = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            questions = try JSONDecoder().decode([TheoryQuestion].self, from: data)
            loadError = nil
        } catch {
            loadError = LocalizationManager.shared.text(.errorTheoryLoad, error.localizedDescription)
            questions = []
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

    var shuffledForQuiz: [TheoryQuestion] {
        questions.shuffled()
    }

    /// Distinct category names from the loaded question bank, largest categories first.
    var categories: [String] {
        var counts: [String: Int] = [:]
        for question in questions {
            counts[question.category, default: 0] += 1
        }
        return counts.keys.sorted { lhs, rhs in
            let left = counts[lhs, default: 0]
            let right = counts[rhs, default: 0]
            if left != right { return left > right }
            return lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
        }
    }

    func questions(in category: String) -> [TheoryQuestion] {
        questions.filter { $0.category == category }
    }

    func count(in category: String) -> Int {
        questions(in: category).count
    }
}
