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

    private init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(forResource: "theory-questions", withExtension: "json") else {
            loadError = "theory-questions.json is missing from the app bundle."
            questions = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            questions = try JSONDecoder().decode([TheoryQuestion].self, from: data)
            loadError = nil
        } catch {
            loadError = "Could not load theory questions: \(error.localizedDescription)"
            questions = []
        }
    }

    var shuffledForQuiz: [TheoryQuestion] {
        questions.shuffled()
    }
}
