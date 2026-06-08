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

    @State private var showingSignDetails = false
    @State private var showExitConfirmation = false
    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScreenTitleBar(
                    title: l10n.text(.signsTitle),
                    showsBackButton: !sessionStore.finished,
                    onBack: { showExitConfirmation = true }
                )

                if !sessionStore.questions.isEmpty, !sessionStore.finished {
                    HStack {
                        Spacer()
                        SignFavoriteButton(
                            signCode: sessionStore.questions[sessionStore.currentIndex].correct.code
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
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
                    Color.clear
                } else if sessionStore.finished {
                    testResult
                } else {
                    activeTest
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
            showingSignDetails = false
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

    private var activeTest: some View {
        let question = sessionStore.questions[sessionStore.currentIndex]

        return VStack(spacing: 0) {
            TestSessionProgressHeader(
                currentIndex: sessionStore.currentIndex,
                totalCount: sessionStore.questions.count
            )

            signPromptCard(for: question.correct)
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, ListCardStyle.rowSpacing)
                .sheet(isPresented: $showingSignDetails) {
                    SignDetailSheet(sign: question.correct)
                }

            QuestionAnswersDivider()

            ScrollView {
                VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                            QuizOptionButton(
                                number: index + 1,
                                title: option.title,
                                state: optionState(for: option, question: question),
                                isInteractive: sessionStore.selectedID == nil
                            ) {
                                sessionStore.select(optionID: option.id, for: question)
                            }
                        }
                    }

                    if sessionStore.selectedID != nil {
                        signMeaningSection(for: question.correct)
                    }
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)

            questionNavigationBar
                .frame(height: 72)
                .background(Theme.screenBackground)
        }
    }

    private func signPromptCard(for sign: Sign) -> some View {
        SignSummaryCard(
            sign: sign,
            maxImageSide: 150,
            showsSignName: false,
            showsInfoButton: sessionStore.selectedID != nil,
            onInfoTap: { showingSignDetails = true }
        )
    }

    private func signMeaningSection(for sign: Sign) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(l10n.text(.studyMeaning))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(sign.meaning)
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

    private var testResult: some View {
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

    private func optionState(for option: QuizOption, question: QuizQuestion) -> QuizOptionState {
        guard let selectedID = sessionStore.selectedID else { return .neutral }
        if option.id == question.correct.id { return .correct }
        if option.id == selectedID { return .incorrect }
        return .neutral
    }
}
