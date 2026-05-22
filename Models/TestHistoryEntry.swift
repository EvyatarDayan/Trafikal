//
//  TestHistoryEntry.swift
//  Trafikal
//

import Foundation

struct TestHistoryEntry: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let date: Date
    let score: Int
    let totalQuestions: Int

    init(id: UUID = UUID(), date: Date = Date(), score: Int, totalQuestions: Int) {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
    }

    var detail: String {
        "\(score)/\(totalQuestions) correct"
    }

    var percentCorrect: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(score) / Double(totalQuestions) * 100).rounded())
    }
}
