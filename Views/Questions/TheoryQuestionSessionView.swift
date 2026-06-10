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
    @State private var showConfetti = false
    @State private var showingQuestionDetails = false
    @State private var navigationDirection: BrowseNavigationDirection = .forward

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
        .confettiOnPerfectTestResult(
            finished: sessionStore.finished,
            score: sessionStore.score,
            total: sessionStore.questions.count,
            showConfetti: $showConfetti
        )
        .onChange(of: sessionStore.finished) { _, isFinished in
            if isFinished {
                sessionStore.recordIfNeeded(historyStore: historyStore)
            }
        }
        .onChange(of: sessionStore.currentIndex) { _, _ in
            showingQuestionDetails = false
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
        VStack(spacing: 0) {
            TestSessionProgressHeader(
                currentIndex: sessionStore.currentIndex,
                totalCount: sessionStore.questions.count
            )

            ZStack {
                testQuestionPage
                    .transition(.browseSlide(navigationDirection))
            }
            .clipped()
            .frame(maxHeight: .infinity)
            .animation(.browsePage, value: sessionStore.currentIndex)

            questionNavigationBar
                .browseNavigationSlot()
        }
        .swipeNavigation(
            onPrevious: goToPreviousQuestion,
            onNext: goToNextQuestion,
            canGoPrevious: sessionStore.currentIndex > 0,
            canGoNext: sessionStore.selectedID != nil
        )
    }

    private var testQuestionPage: some View {
        let item = sessionStore.questions[sessionStore.currentIndex]

        return VStack(spacing: 0) {
            questionCard(
                for: item.source,
                showsInfoButton: sessionStore.selectedID != nil,
                onInfoTap: { showingQuestionDetails = true }
            )
            .padding(.horizontal, ListCardStyle.horizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, ListCardStyle.rowSpacing)
            .sheet(isPresented: $showingQuestionDetails) {
                TheoryQuestionDetailSheet(question: item.source)
            }

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
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }
        .id(sessionStore.currentIndex)
    }

    private func questionCard(
        for question: TheoryQuestion,
        showsInfoButton: Bool,
        onInfoTap: @escaping () -> Void
    ) -> some View {
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
                Text(question.id.ungroupedDisplayString)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(question.question)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
        .overlay(alignment: .topTrailing) {
            if showsInfoButton {
                Button(action: onInfoTap) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(l10n.text(.questionsExplanation))
                .padding(.top, 10)
                .padding(.trailing, 10)
            }
        }
    }

    private var questionNavigationBar: some View {
        TestQuestionNavigationBar(
            canGoBack: sessionStore.currentIndex > 0,
            canGoForward: sessionStore.selectedID != nil,
            forwardTitle: sessionStore.currentIndex < sessionStore.questions.count - 1
                ? l10n.text(.testNextQuestion)
                : l10n.text(.testShowResults),
            onBack: goToPreviousQuestion,
            onForward: goToNextQuestion
        )
    }

    private func goToNextQuestion() {
        guard sessionStore.selectedID != nil else { return }
        navigationDirection = .forward
        withAnimation(.browsePage) {
            sessionStore.advance()
        }
    }

    private func goToPreviousQuestion() {
        guard sessionStore.currentIndex > 0 else { return }
        navigationDirection = .backward
        withAnimation(.browsePage) {
            sessionStore.goBack()
        }
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
