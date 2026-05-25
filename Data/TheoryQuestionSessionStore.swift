//
//  TheoryQuestionSessionStore.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class TheoryQuestionSessionStore {
    static let shared = TheoryQuestionSessionStore()

    private(set) var questions: [TheoryQuizQuestion] = []
    private(set) var questionsPerSession = 10
    private(set) var currentIndex = 0
    private(set) var selectedID: String?
    private(set) var score = 0
    private(set) var finished = false
    private(set) var didRecordCurrentSession = false

    var hasResumableSession: Bool {
        !questions.isEmpty && !finished
    }

    private init() {}

    func startSession(catalog: TheoryQuestionCatalog, questionCount: Int = 10) {
        questionsPerSession = questionCount
        let pool = catalog.shuffledForQuiz
        let count = min(questionsPerSession, pool.count)
        guard count >= 1 else {
            clear()
            return
        }

        questions = pool.prefix(count).map { TheoryQuizQuestion.make(from: $0) }
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        didRecordCurrentSession = false
    }

    func restartSession(catalog: TheoryQuestionCatalog) {
        startSession(catalog: catalog, questionCount: questionsPerSession)
    }

    func clear() {
        questions = []
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        didRecordCurrentSession = false
    }

    func recordIfNeeded(historyStore: TestHistoryStore) {
        guard finished, !didRecordCurrentSession, !questions.isEmpty else { return }
        historyStore.record(score: score, totalQuestions: questions.count, kind: .questions)
        didRecordCurrentSession = true
    }

    func select(optionID: String, for question: TheoryQuizQuestion) {
        guard selectedID == nil else { return }
        selectedID = optionID
        if optionID == question.correctOptionID {
            score += 1
        }
    }

    func advance() {
        guard !questions.isEmpty else { return }

        if currentIndex < questions.count - 1 {
            currentIndex += 1
            selectedID = nil
        } else {
            finished = true
        }
    }
}
