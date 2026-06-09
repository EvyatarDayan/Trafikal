//
//  SimulationSessionStore.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class SimulationSessionStore {
    static let shared = SimulationSessionStore()

    static let scoredItemCount = 65
    static let trialItemCount = 5
    static let itemCount = scoredItemCount + trialItemCount
    /// 70% theory questions, 30% signs — matches exam-style weighting.
    static let theoryShare = 0.7
    static let timeLimitSeconds = 50 * 60
    /// Matches the 80% pass mark for the Swedish theory test (52 of 65).
    static let passMarkPercent = 80

    private(set) var items: [SimulationItem] = []
    private var trialFlags: [Bool] = []
    private(set) var currentIndex = 0
    private(set) var selectedID: String?
    private var answers: [String?] = []
    private(set) var score = 0
    private(set) var finished = false
    private(set) var endedByTimeout = false
    private(set) var didRecordCurrentSession = false
    private(set) var remainingSeconds = timeLimitSeconds

    private var deadline: Date?
    private var timerTask: Task<Void, Never>?
    private var signProgressStore: SignProgressStore?
    private var questionProgressStore: TheoryQuestionProgressStore?

    var hasResumableSession: Bool {
        !items.isEmpty && !finished
    }

    var passed: Bool {
        resultOutcome == .passed
    }

    var resultOutcome: SimulationResultOutcome {
        guard !items.isEmpty else { return .failedLow }
        let percent = score * 100 / Self.scoredItemCount
        if percent >= Self.passMarkPercent { return .passed }
        if percent >= 70 { return .failedAlmostThere }
        return .failedLow
    }

    func isTrialQuestion(at index: Int) -> Bool {
        guard trialFlags.indices.contains(index) else { return false }
        return trialFlags[index]
    }

    private init() {}

    func ensureProgressStores(
        signProgress: SignProgressStore = .shared,
        questionProgress: TheoryQuestionProgressStore = .shared
    ) {
        signProgressStore = signProgress
        questionProgressStore = questionProgress
    }

    func startSession(
        signCatalog: SignCatalog,
        theoryCatalog: TheoryQuestionCatalog,
        signProgress: SignProgressStore = .shared,
        questionProgress: TheoryQuestionProgressStore = .shared
    ) {
        timerTask?.cancel()
        timerTask = nil
        deadline = nil

        ensureProgressStores(signProgress: signProgress, questionProgress: questionProgress)

        let totalTheoryCount = Self.theoryCount(for: Self.itemCount)
        let totalSignCount = Self.itemCount - totalTheoryCount
        let scoredTheoryCount = Self.theoryCount(for: Self.scoredItemCount)
        let scoredSignCount = Self.scoredItemCount - scoredTheoryCount
        let trialTheoryCount = totalTheoryCount - scoredTheoryCount
        let trialSignCount = totalSignCount - scoredSignCount

        guard signCatalog.signs.count >= totalSignCount,
              theoryCatalog.questions.count >= totalTheoryCount else {
            clear()
            return
        }

        let simulationReviewCap = max(1, Self.scoredItemCount / 5)
        let signSelections = signCatalog.generateSmartQuiz(
            totalSigns: totalSignCount,
            progressStore: activeSignProgressStore,
            maxReviewItems: simulationReviewCap
        )
        let theorySelections = theoryCatalog.generateSmartQuiz(
            totalQuestions: totalTheoryCount,
            progressStore: activeQuestionProgressStore,
            maxReviewItems: simulationReviewCap
        )

        guard signSelections.count >= totalSignCount,
              theorySelections.count >= totalTheoryCount else {
            clear()
            return
        }

        let distractorPool = signCatalog.signs
        let randomSigns = signSelections
        let randomTheory = theorySelections

        var pairedItems: [(SimulationItem, Bool)] = []
        pairedItems.reserveCapacity(Self.itemCount)

        pairedItems += randomSigns.prefix(scoredSignCount).map {
            (.sign(QuizQuestion.makeSmart(correct: $0, from: distractorPool)), false)
        }
        pairedItems += randomTheory.prefix(scoredTheoryCount).map {
            (.theory(TheoryQuizQuestion.make(from: $0)), false)
        }
        pairedItems += randomSigns.dropFirst(scoredSignCount).prefix(trialSignCount).map {
            (.sign(QuizQuestion.makeSmart(correct: $0, from: distractorPool)), true)
        }
        pairedItems += randomTheory.dropFirst(scoredTheoryCount).prefix(trialTheoryCount).map {
            (.theory(TheoryQuizQuestion.make(from: $0)), true)
        }
        pairedItems.shuffle()

        let count = pairedItems.count
        guard count >= 2 else {
            clear()
            return
        }

        items = pairedItems.map(\.0)
        trialFlags = pairedItems.map(\.1)
        answers = Array(repeating: nil, count: count)
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        endedByTimeout = false
        didRecordCurrentSession = false
        remainingSeconds = Self.timeLimitSeconds
        deadline = Date().addingTimeInterval(TimeInterval(Self.timeLimitSeconds))
        startTimer()
    }

    func clear() {
        timerTask?.cancel()
        timerTask = nil
        deadline = nil
        items = []
        trialFlags = []
        answers = []
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
        endedByTimeout = false
        didRecordCurrentSession = false
        remainingSeconds = Self.timeLimitSeconds
        signProgressStore = nil
        questionProgressStore = nil
    }

    func recordIfNeeded(historyStore: TestHistoryStore) {
        guard finished, !didRecordCurrentSession, !items.isEmpty else { return }
        historyStore.record(
            score: score,
            totalQuestions: Self.scoredItemCount,
            kind: .simulation,
            mistakes: mistakesForHistory()
        )
        didRecordCurrentSession = true
    }

    func mistakesForHistory() -> [TestHistoryMistake] {
        answers.enumerated().compactMap { index, answer in
            guard let answer, index < items.count, !isTrialQuestion(at: index) else { return nil }
            let item = items[index]
            switch item {
            case .sign(let question):
                guard answer != question.correct.id else { return nil }
                return TestHistoryMistake.from(sign: question, selectedID: answer)
            case .theory(let question):
                guard answer != question.correctOptionID else { return nil }
                return TestHistoryMistake.from(theory: question, selectedID: answer)
            }
        }
    }

    func select(optionID: String, for item: SimulationItem) {
        guard currentIndex < answers.count, answers[currentIndex] == nil else { return }
        answers[currentIndex] = optionID
        selectedID = optionID

        let isTrial = isTrialQuestion(at: currentIndex)
        let isCorrect: Bool
        switch item {
        case .sign(let question):
            isCorrect = optionID == question.correct.id
            if !isTrial {
                activeSignProgressStore.recordAnswer(signCode: question.correct.code, correct: isCorrect)
            }
        case .theory(let question):
            isCorrect = optionID == question.correctOptionID
            if !isTrial {
                activeQuestionProgressStore.recordAnswer(questionID: question.source.id, correct: isCorrect)
            }
        }

        recalculateScore()
    }

    private var activeSignProgressStore: SignProgressStore {
        signProgressStore ?? SignProgressStore.shared
    }

    private var activeQuestionProgressStore: TheoryQuestionProgressStore {
        questionProgressStore ?? TheoryQuestionProgressStore.shared
    }

    func advance() {
        guard !items.isEmpty, answers[currentIndex] != nil else { return }

        if currentIndex < items.count - 1 {
            currentIndex += 1
            selectedID = answers[currentIndex]
        } else {
            finishSession()
        }
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        selectedID = answers[currentIndex]
    }

    private func finishSession() {
        finished = true
        timerTask?.cancel()
        timerTask = nil
    }

    private func recalculateScore() {
        score = answers.enumerated().reduce(0) { partial, entry in
            let (index, answer) = entry
            guard let answer, index < items.count, !isTrialQuestion(at: index) else { return partial }
            return partial + (isCorrectAnswer(answer, for: items[index]) ? 1 : 0)
        }
    }

    private func isCorrectAnswer(_ answerID: String, for item: SimulationItem) -> Bool {
        switch item {
        case .sign(let question):
            answerID == question.correct.id
        case .theory(let question):
            answerID == question.correctOptionID
        }
    }

    private static func theoryCount(for total: Int) -> Int {
        Int((Double(total) * theoryShare).rounded())
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled, !finished {
                try? await Task.sleep(for: .seconds(1))
                tickTimer()
            }
        }
    }

    private func tickTimer() {
        guard !finished, let deadline else { return }

        let secondsLeft = max(0, Int(deadline.timeIntervalSinceNow.rounded(.down)))
        remainingSeconds = secondsLeft

        if secondsLeft <= 0 {
            endedByTimeout = answers.contains(where: { $0 == nil })
            finishSession()
        }
    }
}
