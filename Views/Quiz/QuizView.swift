//
//  QuizView.swift
//  Trafikal
//

import SwiftUI

struct QuizView: View {
    @Environment(SignCatalog.self) private var catalog

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedID: String?
    @State private var score = 0
    @State private var finished = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ScreenTitleBar(title: "Quiz")

                if !questions.isEmpty, !finished {
                    Button("Start over") { startQuiz() }
                        .font(.caption.weight(.medium))
                        .padding(.trailing, 16)
                        .padding(.top, 14)
                }
            }

            Group {
                if let error = catalog.loadError {
                    ContentUnavailableView("No signs", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if finished {
                    quizResult
                } else if questions.isEmpty {
                    ProgressView("Preparing quiz…")
                        .task { startQuiz() }
                } else {
                    activeQuiz
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .appRootScreen()
        .appScreenBackground()
    }

    private var activeQuiz: some View {
        let question = questions[currentIndex]

        return VStack(alignment: .leading, spacing: 20) {
            ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                .padding(.horizontal)

            Text("What does this sign mean?")
                .font(.headline)
                .padding(.horizontal)

            HStack {
                Spacer()
                SignImageView(sign: question.correct)
                Spacer()
            }
            .padding(.vertical)

            VStack(spacing: 12) {
                ForEach(question.options) { option in
                    QuizOptionButton(
                        title: option.title,
                        isSelected: selectedID == option.id,
                        state: optionState(for: option, question: question)
                    ) {
                        select(option: option, question: question)
                    }
                    .disabled(selectedID != nil)
                }
            }
            .padding(.horizontal)

            if selectedID != nil {
                Button(currentIndex < questions.count - 1 ? "Next question" : "Show results") {
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    private var quizResult: some View {
        ContentUnavailableView {
            Label("Done!", systemImage: "checkmark.seal.fill")
        } description: {
            Text("You got \(score) out of \(questions.count) correct.")
        } actions: {
            Button("New quiz") { startQuiz() }
                .buttonStyle(.borderedProminent)
        }
    }

    private func optionState(for option: QuizOption, question: QuizQuestion) -> QuizOptionState {
        guard let selectedID else { return .neutral }
        if option.id == question.correct.id { return .correct }
        if option.id == selectedID { return .incorrect }
        return .neutral
    }

    private func select(option: QuizOption, question: QuizQuestion) {
        selectedID = option.id
        if option.id == question.correct.id {
            score += 1
        }
    }

    private func advance() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            selectedID = nil
        } else {
            finished = true
        }
    }

    private func startQuiz() {
        let pool = catalog.shuffledForQuiz
        let count = min(5, pool.count)
        guard count >= 2 else {
            questions = []
            return
        }

        questions = pool.prefix(count).map { sign in
            QuizQuestion.make(correct: sign, from: pool)
        }
        currentIndex = 0
        selectedID = nil
        score = 0
        finished = false
    }
}

private struct QuizQuestion: Identifiable {
    let id = UUID()
    let correct: Sign
    let options: [QuizOption]

    static func make(correct: Sign, from pool: [Sign]) -> QuizQuestion {
        var distractors = pool.filter { $0.id != correct.id }.shuffled()
        while distractors.count < 3 {
            distractors.append(contentsOf: pool.filter { $0.id != correct.id })
        }
        let wrong = Array(distractors.prefix(3))
        let options = ([correct] + wrong).shuffled().map { sign in
            QuizOption(id: sign.id, title: sign.name)
        }
        return QuizQuestion(correct: correct, options: options)
    }
}

private struct QuizOption: Identifiable {
    let id: String
    let title: String
}

private enum QuizOptionState {
    case neutral, correct, incorrect
}

private struct QuizOptionButton: View {
    let title: String
    let isSelected: Bool
    let state: QuizOptionState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .multilineTextAlignment(.leading)
                Spacer()
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
                    .strokeBorder(borderColor, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch state {
        case .neutral: Color(.secondarySystemBackground)
        case .correct: Color.green.opacity(0.15)
        case .incorrect: Color.red.opacity(0.15)
        }
    }

    private var borderColor: Color {
        switch state {
        case .neutral: Color.clear
        case .correct: .green
        case .incorrect: .red
        }
    }
}
