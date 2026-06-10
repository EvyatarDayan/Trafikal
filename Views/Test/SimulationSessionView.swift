//
//  SimulationSessionView.swift
//  Trafikal
//

import SwiftUI

struct SimulationSessionView: View {
    @Binding var isPresented: Bool

    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(SignCatalog.self) private var signCatalog
    @Environment(TheoryQuestionCatalog.self) private var theoryCatalog
    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(SignProgressStore.self) private var signProgressStore
    @Environment(TheoryQuestionProgressStore.self) private var questionProgressStore
    @Environment(SimulationSessionStore.self) private var sessionStore

    @State private var showingSignDetails = false
    @State private var showingQuestionDetails = false
    @State private var showExitConfirmation = false
    @State private var showTimeUpAlert = false
    @State private var showConfetti = false
    @State private var navigationDirection: BrowseNavigationDirection = .forward

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScreenTitleBar(
                    title: l10n.text(.simulationTitle),
                    showsBackButton: !sessionStore.finished,
                    onBack: { showExitConfirmation = true }
                )

                if !sessionStore.items.isEmpty, !sessionStore.finished, let favoriteTarget = favoriteTarget {
                    HStack {
                        Spacer()
                        favoriteButton(for: favoriteTarget)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }

            Group {
                if catalogLoadError != nil {
                    ContentUnavailableView(
                        l10n.text(.simulationUnavailable),
                        systemImage: "exclamationmark.triangle",
                        description: Text(catalogLoadError ?? "")
                    )
                } else if sessionStore.items.isEmpty, !sessionStore.finished {
                    Color.clear
                } else if sessionStore.finished {
                    sessionResult
                } else {
                    activeItem
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .appScreenBackground()
        .onAppear {
            sessionStore.ensureProgressStores(
                signProgress: signProgressStore,
                questionProgress: questionProgressStore
            )
        }
        .confettiOnPerfectTestResult(
            finished: sessionStore.finished,
            score: sessionStore.score,
            total: SimulationSessionStore.scoredItemCount,
            showConfetti: $showConfetti
        )
        .onChange(of: sessionStore.finished) { _, isFinished in
            if isFinished {
                sessionStore.recordIfNeeded(historyStore: historyStore)
                if sessionStore.endedByTimeout {
                    showTimeUpAlert = true
                }
            }
        }
        .onChange(of: sessionStore.currentIndex) { _, _ in
            showingSignDetails = false
            showingQuestionDetails = false
        }
        .alert(l10n.text(.simulationTimeUp), isPresented: $showTimeUpAlert) {
            Button(l10n.text(.commonOK), role: .cancel) {}
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

    private var catalogLoadError: String? {
        signCatalog.loadError ?? theoryCatalog.loadError
    }

    private var favoriteTarget: SimulationFavoriteTarget? {
        let item = sessionStore.items[sessionStore.currentIndex]
        switch item {
        case .sign(let question):
            return .sign(question.correct.code)
        case .theory(let question):
            return .question(question.source.id)
        }
    }

    @ViewBuilder
    private func favoriteButton(for target: SimulationFavoriteTarget) -> some View {
        switch target {
        case .sign(let code):
            SignFavoriteButton(signCode: code)
        case .question(let id):
            QuestionFavoriteButton(questionID: id)
        }
    }

    private var activeItem: some View {
        VStack(spacing: 0) {
            SimulationSessionProgressHeader(
                currentIndex: sessionStore.currentIndex,
                totalCount: sessionStore.items.count,
                remainingSeconds: sessionStore.remainingSeconds
            )

            ZStack {
                simulationQuestionPage
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

    private var simulationQuestionPage: some View {
        let item = sessionStore.items[sessionStore.currentIndex]

        return VStack(spacing: 0) {
            promptCard(for: item)
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, ListCardStyle.rowSpacing)

            QuestionAnswersDivider(topPadding: 12)

            ScrollView {
                VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                    optionsList(for: item)
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

    @ViewBuilder
    private func promptCard(for item: SimulationItem) -> some View {
        switch item {
        case .sign(let question):
            SignSummaryCard(
                sign: question.correct,
                maxImageSide: 150,
                showsSignName: false,
                showsInfoButton: sessionStore.selectedID != nil,
                onInfoTap: { showingSignDetails = true }
            )
            .sheet(isPresented: $showingSignDetails) {
                SignDetailSheet(sign: question.correct)
            }
        case .theory(let question):
            theoryQuestionCard(
                for: question.source,
                showsInfoButton: sessionStore.selectedID != nil,
                onInfoTap: { showingQuestionDetails = true }
            )
            .sheet(isPresented: $showingQuestionDetails) {
                TheoryQuestionDetailSheet(question: question.source)
            }
        }
    }

    @ViewBuilder
    private func optionsList(for item: SimulationItem) -> some View {
        switch item {
        case .sign(let question):
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                    QuizOptionButton(
                        number: index + 1,
                        title: option.title,
                        state: signOptionState(for: option, question: question),
                        isInteractive: sessionStore.selectedID == nil
                    ) {
                        sessionStore.select(optionID: option.id, for: item)
                    }
                }
            }
        case .theory(let question):
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                    QuizOptionButton(
                        number: index + 1,
                        title: option.title,
                        state: theoryOptionState(for: option, question: question),
                        isInteractive: sessionStore.selectedID == nil
                    ) {
                        sessionStore.select(optionID: option.id, for: item)
                    }
                }
            }
        }
    }

    private func theoryQuestionCard(
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
            forwardTitle: sessionStore.currentIndex < sessionStore.items.count - 1
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
        let outcome = sessionStore.resultOutcome

        return VStack(spacing: 28) {
            Spacer()

            Text(simulationResultTitle(for: outcome))
                .font(.title.weight(.bold))
                .foregroundStyle(simulationResultColor(for: outcome))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TestResultsPieChart(
                statisticsCorrect: sessionStore.score,
                total: SimulationSessionStore.scoredItemCount
            )

            HStack(spacing: 20) {
                legendDot(color: .green, label: l10n.text(.testCorrectCount, sessionStore.score))
                legendDot(
                    color: .red.opacity(0.85),
                    label: l10n.text(
                        .testIncorrectCount,
                        SimulationSessionStore.scoredItemCount - sessionStore.score
                    )
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(
                l10n.text(
                    .testScoreSummary,
                    sessionStore.score,
                    SimulationSessionStore.scoredItemCount
                )
            )
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(
                l10n.text(
                    .simulationTimeLeft,
                    sessionStore.remainingSeconds / 60,
                    sessionStore.remainingSeconds % 60
                )
            )
            .font(.title3.weight(.medium))
            .foregroundStyle(.secondary)
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

    private func simulationResultTitle(for outcome: SimulationResultOutcome) -> String {
        switch outcome {
        case .passed:
            l10n.text(.simulationPassed)
        case .failedAlmostThere:
            l10n.text(.simulationFailedAlmostThere)
        case .failedLow:
            l10n.text(.simulationFailedLow)
        }
    }

    private func simulationResultColor(for outcome: SimulationResultOutcome) -> Color {
        switch outcome {
        case .passed:
            .green
        case .failedAlmostThere:
            .orange
        case .failedLow:
            Color.red.opacity(0.85)
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
        }
    }

    private func signOptionState(for option: QuizOption, question: QuizQuestion) -> QuizOptionState {
        guard let selectedID = sessionStore.selectedID else { return .neutral }
        if option.id == question.correct.id { return .correct }
        if option.id == selectedID { return .incorrect }
        return .neutral
    }

    private func theoryOptionState(for option: QuizOption, question: TheoryQuizQuestion) -> QuizOptionState {
        guard let selectedID = sessionStore.selectedID else { return .neutral }
        if option.id == question.correctOptionID { return .correct }
        if option.id == selectedID { return .incorrect }
        return .neutral
    }
}

private enum SimulationFavoriteTarget {
    case sign(String)
    case question(Int)
}
