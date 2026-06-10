//
//  TheoryQuestionBrowseView.swift
//  Trafikal
//

import SwiftUI

/// Read-only detail for browsing a theory question (with prev/next within the current list).
struct TheoryQuestionBrowseView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme

    let questions: [TheoryQuestion]
    let startIndex: Int

    @State private var index: Int
    @State private var navigationDirection: BrowseNavigationDirection = .forward

    init(questions: [TheoryQuestion], startIndex: Int = 0) {
        self.questions = questions
        self.startIndex = startIndex
        _index = State(initialValue: startIndex)
    }

    private var question: TheoryQuestion {
        questions[index]
    }

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScreenTitleBar(
                    title: l10n.text(.questionsTitle),
                    subtitle: l10n.text(.studyOf, index + 1, questions.count),
                    showsBackButton: true
                )

                HStack {
                    Spacer()
                    QuestionFavoriteButton(questionID: question.id)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            ZStack {
                questionPage
                    .transition(.browseSlide(navigationDirection))
            }
            .clipped()
            .frame(maxHeight: .infinity)
            .animation(.browsePage, value: index)

            navigationSection
                .browseNavigationSlot()
        }
        .appScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .swipeNavigation(
            onPrevious: previous,
            onNext: next,
            canGoPrevious: index > 0,
            canGoNext: index < questions.count - 1
        )
    }

    private var questionPage: some View {
        VStack(spacing: 0) {
            questionCard
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, ListCardStyle.rowSpacing)

            QuestionAnswersDivider(topPadding: 12)

            ScrollView {
                VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { offset, option in
                            optionRow(number: offset + 1, text: option, isCorrect: option == question.answer)
                        }
                    }

                    explanationSection
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .scrollContentBackground(.hidden)
        }
        .id(index)
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(question.id.ungroupedDisplayString)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(question.category)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TheoryQuestionCategoryStyle.accentColor(for: question.category))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5), in: Capsule())

                Spacer(minLength: 0)
            }

            Text(question.question)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
    }

    private var explanationSection: some View {
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

    private func optionRow(number: Int, text: String, isCorrect: Bool) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text("\(number)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isCorrect ? .white : .secondary)
                .frame(width: 26, height: 26)
                .background(isCorrect ? Color.green : Color(.systemGray5), in: Circle())

            Text(text)
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
            if isCorrect {
                RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(Color.green.opacity(0.45), lineWidth: 1.5)
            }
        }
    }

    private var navigationSection: some View {
        BrowseNavigationBar(
            previousTitle: l10n.text(.studyPrevious),
            nextTitle: l10n.text(.studyNext),
            canGoPrevious: index > 0,
            canGoNext: index < questions.count - 1,
            onPrevious: previous,
            onNext: next
        )
    }

    private func next() {
        guard index < questions.count - 1 else { return }
        navigationDirection = .forward
        withAnimation(.browsePage) {
            index += 1
        }
    }

    private func previous() {
        guard index > 0 else { return }
        navigationDirection = .backward
        withAnimation(.browsePage) {
            index -= 1
        }
    }
}
