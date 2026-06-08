//
//  SignProgress.swift
//  Trafikal
//

import Foundation

struct SignProgress: Codable, Sendable, Hashable {
    let signCode: String
    var bucket: QuestionBucket
    var lastAnsweredAt: Date?
    var wrongCount: Int
    var correctStreak: Int
    var lastAnswerWasCorrect: Bool?

    init(
        signCode: String,
        bucket: QuestionBucket = .new,
        lastAnsweredAt: Date? = nil,
        wrongCount: Int = 0,
        correctStreak: Int = 0,
        lastAnswerWasCorrect: Bool? = nil
    ) {
        self.signCode = signCode
        self.bucket = bucket
        self.lastAnsweredAt = lastAnsweredAt
        self.wrongCount = wrongCount
        self.correctStreak = correctStreak
        self.lastAnswerWasCorrect = lastAnswerWasCorrect
    }
}
