//
//  QuestionBucket.swift
//  Trafikal
//

import Foundation

/// Spaced-repetition bucket for theory questions.
/// - Bucket 1: recently missed (reset after a wrong answer)
/// - Bucket 2: answered correctly once (learning)
/// - Bucket 3: answered correctly twice or more (mastered / light review)
enum QuestionBucket: Int, Codable, CaseIterable, Sendable {
    case new = 1
    case learning = 2
    case mastered = 3

    var bucketNumber: Int { rawValue }

    mutating func applyCorrectAnswer() {
        switch self {
        case .new:
            self = .learning
        case .learning:
            self = .mastered
        case .mastered:
            break
        }
    }

    mutating func applyWrongAnswer() {
        self = .new
    }
}

/// Priority used when building a smart quiz.
enum QuestionSelectionPriority: Int, CaseIterable, Sendable {
    /// Answered wrong and not yet proven with consecutive correct answers.
    case needsReview
    /// Never attempted.
    case unseen
    /// Answered correctly once in a row (no recent wrong streak).
    case learning
    /// Answered correctly twice or more in a row.
    case mastered
}
