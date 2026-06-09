//
//  QuizHistoryKind.swift
//  Trafikal
//

import Foundation

enum QuizHistoryKind: String, Codable, Sendable, Hashable {
    case signs
    case questions
    case simulation
}

enum HistoryFilter: String, CaseIterable, Identifiable {
    case all
    case signs
    case questions
    case simulation

    var id: String { rawValue }

    func matches(_ kind: QuizHistoryKind) -> Bool {
        switch self {
        case .all: true
        case .signs: kind == .signs
        case .questions: kind == .questions
        case .simulation: kind == .simulation
        }
    }

    var quizKind: QuizHistoryKind? {
        switch self {
        case .all: nil
        case .signs: .signs
        case .questions: .questions
        case .simulation: .simulation
        }
    }

    func label(using l10n: LocalizationManager) -> String {
        switch self {
        case .all: l10n.text(.historyFilterAll)
        case .signs: l10n.text(.historyFilterSigns)
        case .questions: l10n.text(.historyFilterQuestions)
        case .simulation: l10n.text(.historyFilterSimulation)
        }
    }
}
