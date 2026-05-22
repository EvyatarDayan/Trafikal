//
//  TestQuestionTypes.swift
//  Trafikal
//

import SwiftUI

struct QuizQuestion: Identifiable {
    let id = UUID()
    let correct: Sign
    let options: [QuizOption]

    static func make(correct: Sign, from pool: [Sign]) -> QuizQuestion {
        var usedTitles = Set([correct.name])
        var wrong: [Sign] = []
        for candidate in pool.filter({ $0.id != correct.id }).shuffled() {
            guard !usedTitles.contains(candidate.name) else { continue }
            usedTitles.insert(candidate.name)
            wrong.append(candidate)
            if wrong.count == 3 { break }
        }
        let options = ([correct] + wrong).shuffled().map { sign in
            QuizOption(id: sign.id, title: sign.name)
        }
        return QuizQuestion(correct: correct, options: options)
    }
}

struct QuizOption: Identifiable {
    let id: String
    let title: String
}

enum QuizOptionState {
    case neutral, correct, incorrect
}

struct QuizOptionButton: View {
    let number: Int
    let title: String
    let state: QuizOptionState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text("\(number)")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 22, alignment: .center)

                Text(title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if state == .incorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch state {
        case .neutral: Color(.systemGray6)
        case .correct: Color.green.opacity(0.2)
        case .incorrect: Color.red.opacity(0.2)
        }
    }

    private var borderColor: Color {
        switch state {
        case .neutral: Color(.systemGray3)
        case .correct: .green
        case .incorrect: .red
        }
    }

    private var borderWidth: CGFloat {
        switch state {
        case .neutral: 1.5
        case .correct, .incorrect: 2
        }
    }
}
