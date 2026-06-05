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
    private var answers: [String?] = []
    private(set) var score = 0
    private(set) var finished = false
    private(set) var didRecordCurrentTest = false

    /// In-memory only - cleared when the app terminates or the user ends the test.
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
        answers = Array(repeating: nil, count: questions.count)
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
        answers = []
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        didRecordCurrentTest = false
    }

    func select(optionID: String, for question: QuizQuestion) {
        guard currentIndex < answers.count, answers[currentIndex] == nil else { return }
        answers[currentIndex] = optionID
        selectedID = optionID
        recalculateScore()
    }

    func advance() {
        guard !questions.isEmpty, answers[currentIndex] != nil else { return }

        if currentIndex < questions.count - 1 {
            currentIndex += 1
            selectedID = answers[currentIndex]
        } else {
            finished = true
        }
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        selectedID = answers[currentIndex]
    }

    private func recalculateScore() {
        score = answers.enumerated().reduce(0) { partial, entry in
            let (index, answer) = entry
            guard let answer, index < questions.count else { return partial }
            return partial + (answer == questions[index].correct.id ? 1 : 0)
        }
    }

    func recordIfNeeded(historyStore: TestHistoryStore) {
        guard finished, !didRecordCurrentTest, !questions.isEmpty else { return }
        historyStore.record(score: score, totalQuestions: questions.count, kind: .signs)
        didRecordCurrentTest = true
    }
}
