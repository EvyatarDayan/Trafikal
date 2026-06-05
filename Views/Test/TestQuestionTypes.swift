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
        let wrong = pool
            .filter { $0.id != correct.id }
            .shuffled()
            .reduce(into: [Sign]()) { result, sign in
                guard result.count < 3 else { return }
                guard !result.contains(where: { $0.name == sign.name }), sign.name != correct.name else { return }
                result.append(sign)
            }

        return buildQuestion(correct: correct, wrong: wrong)
    }

    static func makeSmart(correct: Sign, from pool: [Sign]) -> QuizQuestion {
        let wrong = QuizDistractorPicker.selectWrongAnswers(correct: correct, from: pool, count: 3)
        return buildQuestion(correct: correct, wrong: wrong)
    }

    private static func buildQuestion(correct: Sign, wrong: [Sign]) -> QuizQuestion {
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
    @Environment(\.colorScheme) private var colorScheme

    let number: Int
    let title: String
    let state: QuizOptionState
    var isInteractive: Bool = true
    let action: () -> Void

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        Button {
            guard isInteractive else { return }
            action()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Text("\(number)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(numberForeground)
                    .frame(width: 26, height: 26)
                    .background(numberBackground, in: Circle())

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .listCardStyle(
                background: cardBackground,
                horizontalPadding: 12,
                verticalPadding: 12,
                colorScheme: colorScheme
            )
            .overlay {
                if let borderColor = overlayBorderColor {
                    RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .allowsHitTesting(isInteractive)
    }

    private var numberForeground: Color {
        switch state {
        case .neutral: .secondary
        case .correct, .incorrect: .white
        }
    }

    private var numberBackground: Color {
        switch state {
        case .neutral: Color(.systemGray5)
        case .correct: .green
        case .incorrect: .red
        }
    }

    private var overlayBorderColor: Color? {
        switch state {
        case .neutral: nil
        case .correct: Color.green.opacity(0.45)
        case .incorrect: Color.red.opacity(0.45)
        }
    }
}
