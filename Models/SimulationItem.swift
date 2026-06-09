//
//  SimulationItem.swift
//  Trafikal
//

import Foundation

enum SimulationItem: Identifiable {
    case sign(QuizQuestion)
    case theory(TheoryQuizQuestion)

    var id: String {
        switch self {
        case .sign(let question):
            "sign-\(question.correct.id)"
        case .theory(let question):
            "theory-\(question.source.id)"
        }
    }
}
