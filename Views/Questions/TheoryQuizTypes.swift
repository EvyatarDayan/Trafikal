//
//  TheoryQuizTypes.swift
//  Trafikal
//

import Foundation

struct TheoryQuizQuestion: Identifiable {
    let id = UUID()
    let source: TheoryQuestion
    let options: [QuizOption]

    var correctOptionID: String { source.answer }

    static func make(from question: TheoryQuestion) -> TheoryQuizQuestion {
        let options = question.options.shuffled().map { text in
            QuizOption(id: text, title: text)
        }
        return TheoryQuizQuestion(source: question, options: options)
    }
}
