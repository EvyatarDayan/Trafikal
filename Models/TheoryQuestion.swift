//
//  TheoryQuestion.swift
//  Trafikal
//

import Foundation

struct TheoryQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let category: String
    let question: String
    let options: [String]
    let answer: String
    let explanation: String
}
