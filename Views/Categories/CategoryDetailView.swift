//
//  CategoryDetailView.swift
//  Trafikal
//

import SwiftUI

struct CategoryDetailView: View {
    private enum ListingMode: Equatable {
        case allSigns
        case category(SignCategory)
        case favorites
    }

    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(SignCatalog.self) private var catalog
    @Environment(FavoritesStore.self) private var favorites

    private let listingMode: ListingMode

    @State private var searchText = ""

    private let listHorizontalPadding: CGFloat = 16
    private let listVerticalPadding: CGFloat = 8
    private let rowSpacing: CGFloat = 12
    private let rowVerticalPadding: CGFloat = 14
    private let rowHorizontalPadding: CGFloat = 14

    init(category: SignCategory) {
        listingMode = .category(category)
    }

    /// All signs in catalog order (Signs tab - “All traffic signs”).
    init(allSigns: ()) {
        listingMode = .allSigns
    }

    init(favorites: ()) {
        listingMode = .favorites
    }

    private var allSigns: [Sign] {
        switch listingMode {
        case .allSigns:
            catalog.signs
        case .category(let category):
            catalog.signs(in: category)
        case .favorites:
            favorites.favoriteSigns(in: catalog)
        }
    }

    private var screenTitle: String {
        let count = allSigns.count
        switch listingMode {
        case .allSigns:
            return "\(l10n.text(.studyAllSigns)) (\(count))"
        case .category(let category):
            return "\(category.title) (\(count))"
        case .favorites:
            return "\(l10n.text(.favoritesTitle)) (\(count))"
        }
    }

    private var filteredSigns: [Sign] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allSigns }
        return allSigns.filter { sign in
            sign.code.localizedCaseInsensitiveContains(query)
                || sign.name.localizedCaseInsensitiveContains(query)
                || sign.keywords.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: screenTitle,
                showsBackButton: true
            )

            searchField
                .padding(.top, 12)
                .padding(.horizontal, listHorizontalPadding)
                .padding(.bottom, 12)
                .background(Theme.screenBackground)

            Group {
                if filteredSigns.isEmpty, listingMode == .favorites {
                    ContentUnavailableView(
                        l10n.text(.favoritesTitle),
                        systemImage: "heart",
                        description: Text(l10n.text(.favoritesEmptySigns))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: rowSpacing) {
                            ForEach(filteredSigns) { sign in
                                NavigationLink {
                                    StudyCardView(
                                        signs: filteredSigns,
                                        startIndex: filteredSigns.firstIndex(of: sign) ?? 0
                                    )
                                } label: {
                                    signRow(sign)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, listHorizontalPadding)
                        .padding(.top, listVerticalPadding)
                        .padding(.bottom, listVerticalPadding + 8)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
    }

    private var rowBackground: Color {
        colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6)
    }

    private func signRow(_ sign: Sign) -> some View {
        HStack(alignment: .center, spacing: 16) {
            SignImageView(sign: sign, compact: true)

            VStack(alignment: .leading, spacing: 4) {
                Text(sign.code)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(sign.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                if sign.name != sign.meaning {
                    Text(sign.meaning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                if sign.displayValue != nil {
                    Text(sign.displayValue!)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, rowHorizontalPadding)
        .padding(.vertical, rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(colorScheme == .light ? 0.06 : 0), radius: 4, x: 0, y: 2)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(l10n.text(.categoriesSearch), text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
