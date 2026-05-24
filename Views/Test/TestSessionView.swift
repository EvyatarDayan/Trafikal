//
//  TestSessionView.swift
//  Trafikal
//

import SwiftUI

struct TestSessionView: View {
    @Binding var isPresented: Bool

    @Environment(LocalizationManager.self) private var l10n
    @Environment(SignCatalog.self) private var catalog
    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(TestSessionStore.self) private var sessionStore

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScreenTitleBar(
                    title: l10n.text(.signsTitle),
                    showsBackButton: !sessionStore.finished,
                    onBack: { isPresented = false }
                )

                if !sessionStore.questions.isEmpty, !sessionStore.finished {
                    HStack {
                        Spacer()
                        Button(l10n.text(.signsStartOver)) {
                            sessionStore.restartTest(catalog: catalog)
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
                        l10n.text(.signsNoSigns),
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if sessionStore.questions.isEmpty, !sessionStore.finished {
                    ProgressView(l10n.text(.signsPreparing))
                        .task {
                            sessionStore.startTest(catalog: catalog)
                        }
                } else if sessionStore.finished {
                    testResult
                } else {
                    activeTest
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .appScreenBackground()
        .onChange(of: sessionStore.finished) { _, isFinished in
            if isFinished {
                sessionStore.recordIfNeeded(historyStore: historyStore)
            }
        }
    }

    private var activeTest: some View {
        let question = sessionStore.questions[sessionStore.currentIndex]

        return VStack(alignment: .leading, spacing: 20) {
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

            Text(l10n.text(.signsWhatDoesSignMean))
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
                        sessionStore.select(optionID: option.id, for: question)
                    }
                    .disabled(sessionStore.selectedID != nil)
                }
            }
            .padding(.horizontal)

            if sessionStore.selectedID != nil {
                Button(
                    sessionStore.currentIndex < sessionStore.questions.count - 1
                        ? l10n.text(.testNextQuestion)
                        : l10n.text(.testShowResults)
                ) {
                    sessionStore.advance()
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

            TestResultsPieChart(correct: sessionStore.score, total: sessionStore.questions.count)

            HStack(spacing: 20) {
                legendDot(color: .green, label: l10n.text(.testCorrectCount, sessionStore.score))
                legendDot(
                    color: .red.opacity(0.85),
                    label: l10n.text(.testIncorrectCount, sessionStore.questions.count - sessionStore.score)
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(l10n.text(.testScoreSummary, sessionStore.score, sessionStore.questions.count))
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(l10n.text(.signsEnd)) {
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

    private func optionState(for option: QuizOption, question: QuizQuestion) -> QuizOptionState {
        guard let selectedID = sessionStore.selectedID else { return .neutral }
        if option.id == question.correct.id { return .correct }
        if option.id == selectedID { return .incorrect }
        return .neutral
    }
}
