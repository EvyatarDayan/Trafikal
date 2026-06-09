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
    let mistakes: [TestHistoryMistake]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        score: Int,
        totalQuestions: Int,
        kind: QuizHistoryKind,
        mistakes: [TestHistoryMistake] = []
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.kind = kind
        self.mistakes = mistakes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        score = try container.decode(Int.self, forKey: .score)
        totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        kind = try container.decodeIfPresent(QuizHistoryKind.self, forKey: .kind) ?? .signs
        mistakes = try container.decodeIfPresent([TestHistoryMistake].self, forKey: .mistakes) ?? []
    }

    var hasMistakes: Bool {
        !mistakes.isEmpty
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
        case .simulation:
            l10n.text(.simulationHistoryTitle)
        }
    }

    var percentCorrect: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(score) / Double(totalQuestions) * 100).rounded())
    }

    var passed: Bool {
        percentCorrect >= SimulationSessionStore.passMarkPercent
    }
}

struct RecentTestAggregate: Sendable {
    let testCount: Int
    let correctCount: Int
    let totalQuestions: Int

    var averagePercent: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(correctCount) / Double(totalQuestions) * 100).rounded())
    }
}
