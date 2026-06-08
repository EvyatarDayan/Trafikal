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

    private var progressStore: SignProgressStore?

    /// In-memory only - cleared when the app terminates or the user ends the test.
    var hasResumableSession: Bool {
        !questions.isEmpty && !finished
    }

    private init() {}

    func ensureProgressStore(_ store: SignProgressStore = .shared) {
        progressStore = store
    }

    func startTest(
        catalog: SignCatalog,
        progressStore: SignProgressStore = .shared,
        questionCount: Int = 10
    ) {
        questionsPerTest = questionCount
        ensureProgressStore(progressStore)

        let selectedSigns = catalog.generateSmartQuiz(
            totalSigns: questionCount,
            progressStore: progressStore
        )
        let count = min(questionsPerTest, selectedSigns.count)
        guard count >= 2 else {
            clear()
            return
        }

        let distractorPool = catalog.signs
        questions = selectedSigns.prefix(count).map { sign in
            QuizQuestion.makeSmart(correct: sign, from: distractorPool)
        }
        answers = Array(repeating: nil, count: questions.count)
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        didRecordCurrentTest = false
    }

    func restartTest(
        catalog: SignCatalog,
        progressStore: SignProgressStore = .shared
    ) {
        startTest(
            catalog: catalog,
            progressStore: progressStore,
            questionCount: questionsPerTest
        )
    }

    func clear() {
        questions = []
        answers = []
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        didRecordCurrentTest = false
        progressStore = nil
    }

    func select(optionID: String, for question: QuizQuestion) {
        guard currentIndex < answers.count, answers[currentIndex] == nil else { return }
        answers[currentIndex] = optionID
        selectedID = optionID
        recalculateScore()

        let isCorrect = optionID == question.correct.id
        activeProgressStore.recordAnswer(signCode: question.correct.code, correct: isCorrect)
    }

    private var activeProgressStore: SignProgressStore {
        progressStore ?? SignProgressStore.shared
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
