//
//  QuizHistoryKind.swift
//  Trafikal
//

import Foundation

enum QuizHistoryKind: String, Codable, Sendable, Hashable {
    case signs
    case questions
}

enum HistoryFilter: String, CaseIterable, Identifiable {
    case all
    case signs
    case questions

    var id: String { rawValue }

    func matches(_ kind: QuizHistoryKind) -> Bool {
        switch self {
        case .all: true
        case .signs: kind == .signs
        case .questions: kind == .questions
        }
    }

    var quizKind: QuizHistoryKind? {
        switch self {
        case .all: nil
        case .signs: .signs
        case .questions: .questions
        }
    }

    func label(using l10n: LocalizationManager) -> String {
        switch self {
        case .all: l10n.text(.historyFilterAll)
        case .signs: l10n.text(.historyFilterSigns)
        case .questions: l10n.text(.historyFilterQuestions)
        }
    }
}
