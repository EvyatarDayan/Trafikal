//
//  TestSessionView.swift
//  Trafikal
//

import SwiftUI

struct TestSessionView: View {
    private let questionsPerTest = 10

    @Environment(\.dismiss) private var dismiss
    @Environment(SignCatalog.self) private var catalog
    @Environment(TestHistoryStore.self) private var historyStore

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedID: String?
    @State private var score = 0
    @State private var finished = false
    @State private var didRecordCurrentTest = false
    @State private var didStart = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScreenTitleBar(title: "Test", showsBackButton: !finished)

                if !questions.isEmpty, !finished {
                    HStack {
                        Spacer()
                        Button("Start over") { startTest() }
                            .font(.caption.weight(.medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                }
            }

            Group {
                if let error = catalog.loadError {
                    ContentUnavailableView("No signs", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if !didStart || (questions.isEmpty && !finished) {
                    ProgressView("Preparing test…")
                } else if finished {
                    testResult
                } else {
                    activeTest
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .appScreenBackground()
        .onAppear {
            guard !didStart else { return }
            didStart = true
            startTest()
        }
        .onChange(of: finished) { _, isFinished in
            if isFinished {
                recordCompletedTestIfNeeded()
            }
        }
    }

    private var activeTest: some View {
        let question = questions[currentIndex]

        return VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 6) {
                ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                Text("\(currentIndex + 1)/\(questions.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
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
                ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                    QuizOptionButton(
                        number: index + 1,
                        title: option.title,
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

    private var testResult: some View {
        VStack(spacing: 28) {
            Spacer()

            TestResultsPieChart(correct: score, total: questions.count)

            HStack(spacing: 20) {
                legendDot(color: .green, label: "Correct (\(score))")
                legendDot(color: .red.opacity(0.85), label: "Incorrect (\(questions.count - score))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("You got \(score) out of \(questions.count) correct.")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button("End this test") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
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

    private func startTest() {
        let pool = catalog.shuffledForQuiz
        let count = min(questionsPerTest, pool.count)
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
        didRecordCurrentTest = false
    }

    private func recordCompletedTestIfNeeded() {
        guard !didRecordCurrentTest, !questions.isEmpty else { return }
        historyStore.record(score: score, totalQuestions: questions.count)
        didRecordCurrentTest = true
    }
}
