//
//  TestHistoryMistake.swift
//  Trafikal
//

import Foundation

struct TestHistoryMistakeOption: Codable, Sendable, Hashable, Identifiable {
    let id: String
    let title: String
}

enum TestHistoryMistakeKind: String, Codable, Sendable {
    case sign
    case theory
}

struct TestHistoryMistake: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let kind: TestHistoryMistakeKind
    let sign: Sign?
    let questionID: Int?
    let category: String?
    let questionText: String?
    let explanation: String?
    let options: [TestHistoryMistakeOption]
    let selectedOptionID: String
    let correctOptionID: String

    static func from(sign question: QuizQuestion, selectedID: String) -> TestHistoryMistake {
        TestHistoryMistake(
            id: UUID(),
            kind: .sign,
            sign: question.correct,
            questionID: nil,
            category: nil,
            questionText: nil,
            explanation: nil,
            options: question.options.map { TestHistoryMistakeOption(id: $0.id, title: $0.title) },
            selectedOptionID: selectedID,
            correctOptionID: question.correct.id
        )
    }

    static func from(theory question: TheoryQuizQuestion, selectedID: String) -> TestHistoryMistake {
        let source = question.source
        return TestHistoryMistake(
            id: UUID(),
            kind: .theory,
            sign: nil,
            questionID: source.id,
            category: source.category,
            questionText: source.question,
            explanation: source.explanation,
            options: question.options.map { TestHistoryMistakeOption(id: $0.id, title: $0.title) },
            selectedOptionID: selectedID,
            correctOptionID: question.correctOptionID
        )
    }

    var theoryQuestion: TheoryQuestion? {
        guard kind == .theory,
              let questionID,
              let category,
              let questionText,
              let explanation else { return nil }
        return TheoryQuestion(
            id: questionID,
            category: category,
            question: questionText,
            options: options.map(\.title),
            answer: correctOptionID,
            explanation: explanation
        )
    }
}
