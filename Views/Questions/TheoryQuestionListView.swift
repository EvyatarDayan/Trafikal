//
//  TheoryQuestionListView.swift
//  Trafikal
//

import SwiftUI

struct TheoryQuestionListView: View {
    private enum ListingMode: Equatable {
        case all
        case category(String)
        case favorites
    }

    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(TheoryQuestionCatalog.self) private var catalog
    @Environment(FavoritesStore.self) private var favorites

    private let listingMode: ListingMode

    @State private var searchText = ""

    init(category: String?) {
        if let category {
            listingMode = .category(category)
        } else {
            listingMode = .all
        }
    }

    init(favorites: ()) {
        listingMode = .favorites
    }

    private var allQuestions: [TheoryQuestion] {
        switch listingMode {
        case .all:
            catalog.questions
        case .category(let category):
            catalog.questions(in: category)
        case .favorites:
            favorites.favoriteQuestions(in: catalog)
        }
    }

    private var screenTitle: String {
        let count = allQuestions.count
        let countLabel = count.ungroupedDisplayString
        switch listingMode {
        case .all:
            return "\(l10n.text(.questionsAllQuestions)) (\(countLabel))"
        case .category(let category):
            return "\(category) (\(countLabel))"
        case .favorites:
            return "\(l10n.text(.favoritesTitle)) (\(countLabel))"
        }
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

    private var categoryIconBackground: Color {
        colorScheme == .light ? Color(.systemGray6) : Color(.systemGray5)
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

            Group {
                if filteredQuestions.isEmpty, listingMode == .favorites {
                    ContentUnavailableView(
                        l10n.text(.favoritesTitle),
                        systemImage: "heart",
                        description: Text(l10n.text(.favoritesEmptyQuestions))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
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
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
    }

    private func questionRow(_ question: TheoryQuestion) -> some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .topLeading) {
                Image(systemName: TheoryQuestionCategoryStyle.systemImage(for: question.category))
                    .font(.system(size: 36))
                    .foregroundStyle(TheoryQuestionCategoryStyle.accentColor(for: question.category))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Text(question.id.ungroupedDisplayString)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .padding(6)
            }
            .frame(width: 88, height: 88)
            .background(
                categoryIconBackground,
                in: RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
            )

            Text(question.question)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

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
