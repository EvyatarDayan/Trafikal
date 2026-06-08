//
//  TheoryQuestionProgress.swift
//  Trafikal
//

import Foundation

struct TheoryQuestionProgress: Codable, Sendable, Hashable {
    let questionID: Int
    var bucket: QuestionBucket
    var lastAnsweredAt: Date?
    /// Total number of wrong answers — used to prioritize the most-missed questions.
    var wrongCount: Int
    /// Consecutive correct answers — resets on every wrong answer.
    var correctStreak: Int
    /// Result of the most recent attempt — drives repeat selection.
    var lastAnswerWasCorrect: Bool?

    init(
        questionID: Int,
        bucket: QuestionBucket = .new,
        lastAnsweredAt: Date? = nil,
        wrongCount: Int = 0,
        correctStreak: Int = 0,
        lastAnswerWasCorrect: Bool? = nil
    ) {
        self.questionID = questionID
        self.bucket = bucket
        self.lastAnsweredAt = lastAnsweredAt
        self.wrongCount = wrongCount
        self.correctStreak = correctStreak
        self.lastAnswerWasCorrect = lastAnswerWasCorrect
    }
}

extension TheoryQuestion {
    func selectionPriority(in progressStore: TheoryQuestionProgressStore) -> QuestionSelectionPriority {
        progressStore.selectionPriority(for: id)
    }
}
