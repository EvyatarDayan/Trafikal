//
//  TheoryQuestionListView.swift
//  Trafikal
//

import SwiftUI

struct TheoryQuestionListView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(TheoryQuestionCatalog.self) private var catalog

    private let category: String?

    @State private var searchText = ""

    init(category: String?) {
        self.category = category
    }

    private var allQuestions: [TheoryQuestion] {
        if let category {
            catalog.questions(in: category)
        } else {
            catalog.questions
        }
    }

    private var screenTitle: String {
        let count = allQuestions.count
        if let category {
            return "\(category) (\(count))"
        }
        return "\(l10n.text(.questionsAllQuestions)) (\(count))"
    }

    private var filteredQuestions: [TheoryQuestion] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allQuestions }
        return allQuestions.filter { question in
            String(question.id).contains(query)
                || question.category.localizedCaseInsensitiveContains(query)
                || question.question.localizedCaseInsensitiveContains(query)
                || question.options.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: screenTitle,
                showsBackButton: true
            )

            searchField
                .padding(.top, 12)
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.bottom, 12)
                .background(Theme.screenBackground)

            ScrollView {
                LazyVStack(spacing: ListCardStyle.rowSpacing) {
                    ForEach(filteredQuestions) { question in
                        NavigationLink {
                            TheoryQuestionBrowseView(
                                questions: filteredQuestions,
                                startIndex: filteredQuestions.firstIndex(of: question) ?? 0
                            )
                        } label: {
                            questionRow(question)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, ListCardStyle.rowSpacing)
                .padding(.bottom, 16)
            }
            .scrollContentBackground(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
    }

    private func questionRow(_ question: TheoryQuestion) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: TheoryQuestionCategoryStyle.systemImage(for: question.category))
                .font(.system(size: 36))
                .foregroundStyle(TheoryQuestionCategoryStyle.accentColor(for: question.category))
                .frame(width: 88, height: 88)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(question.id)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(question.question)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(question.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(l10n.text(.questionsSearch), text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
    }
}
