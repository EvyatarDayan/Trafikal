//
//  TheoryQuestionSessionView.swift
//  Trafikal
//

import SwiftUI

struct TheoryQuestionSessionView: View {
    @Binding var isPresented: Bool

    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(TheoryQuestionCatalog.self) private var catalog
    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(TheoryQuestionSessionStore.self) private var sessionStore

    @State private var showExitConfirmation = false

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScreenTitleBar(
                    title: l10n.text(.questionsTitle),
                    showsBackButton: !sessionStore.finished,
                    onBack: { showExitConfirmation = true }
                )

                if !sessionStore.questions.isEmpty, !sessionStore.finished {
                    HStack {
                        Spacer()
                        QuestionFavoriteButton(
                            questionID: sessionStore.questions[sessionStore.currentIndex].source.id
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }

            Group {
                if let error = catalog.loadError {
                    ContentUnavailableView(
                        l10n.text(.questionsNoQuestions),
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if sessionStore.finished {
                    sessionResult
                } else if sessionStore.questions.isEmpty {
                    Color.clear
                } else {
                    activeQuestion
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
        .alert(l10n.text(.testExitAlertTitle), isPresented: $showExitConfirmation) {
            Button(l10n.text(.commonCancel), role: .cancel) {}
            Button(l10n.text(.commonOK)) {
                sessionStore.clear()
                isPresented = false
            }
        } message: {
            Text(l10n.text(.testExitAlertMessage))
        }
    }

    private var activeQuestion: some View {
        let item = sessionStore.questions[sessionStore.currentIndex]

        return VStack(spacing: 0) {
            TestSessionProgressHeader(
                currentIndex: sessionStore.currentIndex,
                totalCount: sessionStore.questions.count
            )

            questionCard(for: item.source)
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, ListCardStyle.rowSpacing)

            QuestionAnswersDivider(topPadding: 12)

            ScrollView {
                VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(item.options.enumerated()), id: \.element.id) { index, option in
                            QuizOptionButton(
                                number: index + 1,
                                title: option.title,
                                state: optionState(for: option, question: item),
                                isInteractive: sessionStore.selectedID == nil
                            ) {
                                sessionStore.select(optionID: option.id, for: item)
                            }
                        }
                    }

                    if sessionStore.selectedID != nil {
                        explanationSection(for: item.source)
                    }
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .id(item.source.id)

            questionNavigationBar
                .frame(height: 72)
                .background(Theme.screenBackground)
        }
    }

    private func questionCard(for question: TheoryQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.category)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TheoryQuestionCategoryStyle.accentColor(for: question.category))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.systemGray5), in: Capsule())

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(question.id)")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(question.question)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
    }

    private func explanationSection(for question: TheoryQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(l10n.text(.questionsExplanation))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(question.explanation)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var questionNavigationBar: some View {
        TestQuestionNavigationBar(
            canGoBack: sessionStore.currentIndex > 0,
            canGoForward: sessionStore.selectedID != nil,
            forwardTitle: sessionStore.currentIndex < sessionStore.questions.count - 1
                ? l10n.text(.testNextQuestion)
                : l10n.text(.testShowResults),
            onBack: { sessionStore.goBack() },
            onForward: { sessionStore.advance() }
        )
    }

    private var sessionResult: some View {
        VStack(spacing: 28) {
            Spacer()

            TestResultsPieChart(
                statisticsCorrect: sessionStore.score,
                total: sessionStore.questions.count
            )

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

            Button(l10n.text(.commonDone)) {
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
