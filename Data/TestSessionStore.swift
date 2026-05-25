//
//  TestSessionStore.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class TestSessionStore {
    static let shared = TestSessionStore()

    private(set) var questions: [QuizQuestion] = []
    private(set) var questionsPerTest = 10
    private(set) var currentIndex = 0
    private(set) var selectedID: String?
    private(set) var score = 0
    private(set) var finished = false
    private(set) var didRecordCurrentTest = false

    /// In-memory only — cleared when the app terminates or the user ends the test.
    var hasResumableSession: Bool {
        !questions.isEmpty && !finished
    }

    private init() {}

    func startTest(catalog: SignCatalog, questionCount: Int = 10) {
        questionsPerTest = questionCount
        let pool = catalog.shuffledForQuiz
        let count = min(questionsPerTest, pool.count)
        guard count >= 2 else {
            clear()
            return
        }

        questions = pool.prefix(count).map { sign in
            QuizQuestion.makeSmart(correct: sign, from: pool)
        }
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        didRecordCurrentTest = false
    }

    func restartTest(catalog: SignCatalog) {
        startTest(catalog: catalog, questionCount: questionsPerTest)
    }

    func clear() {
        questions = []
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        didRecordCurrentTest = false
    }

    func select(optionID: String, for question: QuizQuestion) {
        guard selectedID == nil else { return }
        selectedID = optionID
        if optionID == question.correct.id {
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

    func recordIfNeeded(historyStore: TestHistoryStore) {
        guard finished, !didRecordCurrentTest, !questions.isEmpty else { return }
        historyStore.record(score: score, totalQuestions: questions.count, kind: .signs)
        didRecordCurrentTest = true
    }
}
