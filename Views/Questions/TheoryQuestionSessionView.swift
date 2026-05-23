//
//  TheoryQuestionSessionView.swift
//  Trafikal
//

import SwiftUI

struct TheoryQuestionSessionView: View {
    @Binding var isPresented: Bool

    @Environment(TheoryQuestionCatalog.self) private var catalog
    @Environment(TheoryQuestionSessionStore.self) private var sessionStore

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScreenTitleBar(
                    title: "Questions",
                    showsBackButton: !sessionStore.finished,
                    onBack: { isPresented = false }
                )

                if !sessionStore.questions.isEmpty, !sessionStore.finished {
                    HStack {
                        Spacer()
                        Button("Start over") {
                            sessionStore.restartSession(catalog: catalog)
                        }
                        .font(.caption.weight(.medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                }
            }

            Group {
                if let error = catalog.loadError {
                    ContentUnavailableView(
                        "No questions",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if sessionStore.questions.isEmpty, !sessionStore.finished {
                    ProgressView("Preparing questions…")
                        .task {
                            sessionStore.startSession(catalog: catalog)
                        }
                } else if sessionStore.finished {
                    sessionResult
                } else {
                    activeQuestion
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .appScreenBackground()
    }

    private var activeQuestion: some View {
        let item = sessionStore.questions[sessionStore.currentIndex]

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 6) {
                    ProgressView(
                        value: Double(sessionStore.currentIndex + 1),
                        total: Double(sessionStore.questions.count)
                    )
                    Text("\(sessionStore.currentIndex + 1)/\(sessionStore.questions.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                Text(item.source.category)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5), in: Capsule())
                    .padding(.horizontal)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(item.source.id)")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(item.source.question)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(Array(item.options.enumerated()), id: \.element.id) { index, option in
                        QuizOptionButton(
                            number: index + 1,
                            title: option.title,
                            state: optionState(for: option, question: item)
                        ) {
                            sessionStore.select(optionID: option.id, for: item)
                        }
                        .disabled(sessionStore.selectedID != nil)
                    }
                }
                .padding(.horizontal)

                if sessionStore.selectedID != nil {
                    Text(item.source.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal)

                    Button(
                        sessionStore.currentIndex < sessionStore.questions.count - 1
                            ? "Next question"
                            : "Show results"
                    ) {
                        sessionStore.advance()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private var sessionResult: some View {
        VStack(spacing: 28) {
            Spacer()

            TestResultsPieChart(correct: sessionStore.score, total: sessionStore.questions.count)

            HStack(spacing: 20) {
                legendDot(color: .green, label: "Correct (\(sessionStore.score))")
                legendDot(
                    color: .red.opacity(0.85),
                    label: "Incorrect (\(sessionStore.questions.count - sessionStore.score))"
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("You got \(sessionStore.score) out of \(sessionStore.questions.count) correct.")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button("End this test") {
                sessionStore.clear()
                isPresented = false
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

    private func optionState(for option: QuizOption, question: TheoryQuizQuestion) -> QuizOptionState {
        guard let selectedID = sessionStore.selectedID else { return .neutral }
        if option.id == question.correctOptionID { return .correct }
        if option.id == selectedID { return .incorrect }
        return .neutral
    }
}
