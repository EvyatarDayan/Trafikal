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
    private var answers: [String?] = []
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
        answers = Array(repeating: nil, count: questions.count)
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
        answers = []
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
            return partial + (answer == questions[index].correctOptionID ? 1 : 0)
        }
    }
}
