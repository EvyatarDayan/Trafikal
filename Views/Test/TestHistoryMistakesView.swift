//
//  TestHistoryMistakesView.swift
//  Trafikal
//

import SwiftUI

struct TestHistoryMistakesView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme

    let entry: TestHistoryEntry
    let onBack: () -> Void

    @State private var currentIndex = 0
    @State private var navigationDirection: BrowseNavigationDirection = .forward
    @State private var showingSignDetails = false
    @State private var showingQuestionDetails = false

    private var mistakes: [TestHistoryMistake] {
        entry.mistakes
    }

    private var screenBackground: Color {
        Theme.quizScreenBackground(colorScheme: colorScheme)
    }

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: l10n.text(.historyMistakesTitle),
                subtitle: l10n.text(.historyMistakeProgress, currentIndex + 1, mistakes.count),
                showsBackButton: true,
                onBack: onBack,
                background: screenBackground
            )

            if mistakes.isEmpty {
                ContentUnavailableView(
                    l10n.text(.historyNoMistakesTitle),
                    systemImage: "checkmark.circle",
                    description: Text(l10n.text(.historyNoMistakesMessage))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    mistakePage
                        .transition(.browseSlide(navigationDirection))
                }
                .clipped()
                .frame(maxHeight: .infinity)
                .animation(.browsePage, value: currentIndex)

                navigationBar
                    .browseNavigationSlot(background: screenBackground)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            screenBackground
                .ignoresSafeArea()
        }
        .swipeNavigation(
            onPrevious: goToPrevious,
            onNext: goToNext,
            canGoPrevious: currentIndex > 0,
            canGoNext: currentIndex < mistakes.count - 1
        )
        .onChange(of: currentIndex) { _, _ in
            showingSignDetails = false
            showingQuestionDetails = false
        }
    }

    private var mistakePage: some View {
        let mistake = mistakes[currentIndex]

        return VStack(spacing: 0) {
            promptSection(for: mistake)
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, ListCardStyle.rowSpacing)

            QuestionAnswersDivider()

            ScrollView {
                VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(mistake.options.enumerated()), id: \.element.id) { index, option in
                            QuizOptionButton(
                                number: index + 1,
                                title: option.title,
                                state: optionState(for: option, mistake: mistake),
                                isInteractive: false
                            ) {}
                        }
                    }

                    if mistake.kind == .sign, let sign = mistake.sign {
                        signMeaningSection(for: sign)
                    }
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }
        .id(currentIndex)
    }

    @ViewBuilder
    private func promptSection(for mistake: TestHistoryMistake) -> some View {
        switch mistake.kind {
        case .sign:
            if let sign = mistake.sign {
                SignSummaryCard(
                    sign: sign,
                    maxImageSide: 150,
                    showsSignName: false,
                    showsInfoButton: true,
                    onInfoTap: { showingSignDetails = true }
                )
                .sheet(isPresented: $showingSignDetails) {
                    SignDetailSheet(sign: sign)
                }
            }
        case .theory:
            if let question = mistake.theoryQuestion {
                theoryQuestionCard(for: question)
                    .sheet(isPresented: $showingQuestionDetails) {
                        TheoryQuestionDetailSheet(question: question)
                    }
            }
        }
    }

    private func theoryQuestionCard(for question: TheoryQuestion) -> some View {
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
            Button(action: { showingQuestionDetails = true }) {
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

    private var navigationBar: some View {
        TestQuestionNavigationBar(
            canGoBack: currentIndex > 0,
            canGoForward: currentIndex < mistakes.count - 1,
            forwardTitle: l10n.text(.testNextQuestion),
            onBack: goToPrevious,
            onForward: goToNext
        )
    }

    private func goToNext() {
        guard currentIndex < mistakes.count - 1 else { return }
        navigationDirection = .forward
        withAnimation(.browsePage) {
            currentIndex += 1
        }
    }

    private func goToPrevious() {
        guard currentIndex > 0 else { return }
        navigationDirection = .backward
        withAnimation(.browsePage) {
            currentIndex -= 1
        }
    }

    private func optionState(for option: TestHistoryMistakeOption, mistake: TestHistoryMistake) -> QuizOptionState {
        if option.id == mistake.correctOptionID { return .correct }
        if option.id == mistake.selectedOptionID { return .incorrect }
        return .neutral
    }
}
