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
    let kind: QuizHistoryKind

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        score: Int,
        totalQuestions: Int,
        kind: QuizHistoryKind
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.kind = kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        score = try container.decode(Int.self, forKey: .score)
        totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        kind = try container.decodeIfPresent(QuizHistoryKind.self, forKey: .kind) ?? .signs
    }

    func detail(using l10n: LocalizationManager) -> String {
        l10n.text(.historyDetailFormat, score, totalQuestions)
    }

    func title(using l10n: LocalizationManager) -> String {
        switch kind {
        case .signs:
            l10n.text(.signsRoadSignQuiz)
        case .questions:
            l10n.text(.questionsTheoryQuiz)
        }
    }

    var percentCorrect: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(score) / Double(totalQuestions) * 100).rounded())
    }
}
