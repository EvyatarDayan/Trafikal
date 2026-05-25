//
//  QuestionsTabRoot.swift
//  Trafikal
//

import SwiftUI

private enum TheoryQuestionListRoute: Hashable {
    case all
    case category(String)
}

/// Questions tab root — browse all theory questions by category.
struct QuestionsTabRoot: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(TheoryQuestionCatalog.self) private var catalog

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: l10n.text(.questionsTitle))

            ScrollView {
                LazyVStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                    if let error = catalog.loadError {
                        Text(error)
                            .foregroundStyle(.red)
                    }

                    sectionHeader(l10n.text(.questionsBrowse))

                    NavigationLink(value: TheoryQuestionListRoute.all) {
                        allQuestionsRow
                    }
                    .buttonStyle(.plain)

                    Text(l10n.text(.questionsBrowseFooter, catalog.questions.count))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)

                    sectionHeader(l10n.text(.questionsByCategory))

                    ForEach(catalog.categories, id: \.self) { category in
                        let count = catalog.count(in: category)
                        NavigationLink(value: TheoryQuestionListRoute.category(category)) {
                            categoryRow(category: category, count: count)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
            .scrollContentBackground(.hidden)
        }
        .appRootScreen()
        .appScreenBackground()
        .navigationDestination(for: TheoryQuestionListRoute.self) { route in
            switch route {
            case .all:
                TheoryQuestionListView(category: nil)
            case .category(let category):
                TheoryQuestionListView(category: category)
            }
        }
    }

    private var allQuestionsRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "text.book.closed.fill")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(l10n.text(.questionsAllQuestions))
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(l10n.text(.questionsCountFormat, catalog.questions.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
    }

    private func categoryRow(category: String, count: Int) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: TheoryQuestionCategoryStyle.systemImage(for: category))
                .font(.title2)
                .foregroundStyle(TheoryQuestionCategoryStyle.accentColor(for: category))
                .frame(width: 32)

            Text(category)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 0)

            Text("\(count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
            .padding(.bottom, 2)
    }
}
