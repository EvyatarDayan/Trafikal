//
//  QuestionsTabRoot.swift
//  Trafikal
//

import SwiftUI

private enum TheoryQuestionListRoute: Hashable {
    case all
    case favorites
    case category(String)
}

/// Questions practice browse root (all questions and categories).
struct QuestionsTabRoot: View {
    var showsTitleBar: Bool = true

    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(TheoryQuestionCatalog.self) private var catalog
    @Environment(FavoritesStore.self) private var favorites

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            if showsTitleBar {
                ScreenTitleBar(title: l10n.text(.questionsTitle))
            }

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

                    sectionHeader(l10n.text(.studyQuickStart))

                    NavigationLink(value: TheoryQuestionListRoute.favorites) {
                        favoritesRow
                    }
                    .buttonStyle(.plain)

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
        .navigationDestination(for: TheoryQuestionListRoute.self) { route in
            switch route {
            case .all:
                TheoryQuestionListView(category: nil)
            case .favorites:
                TheoryQuestionListView(favorites: ())
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
                .frame(width: 48, height: 48)

            Text(l10n.text(.questionsAllQuestions))
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            Text("\(catalog.questions.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
    }

    private var favoritesRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(.red)
                .frame(width: 48, height: 48)

            Text(l10n.text(.favoritesTitle))
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            Text("\(favorites.questionIDs.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

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
                .frame(width: 48, height: 48)

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
