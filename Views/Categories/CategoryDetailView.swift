//
//  CategoryDetailView.swift
//  Trafikal
//

import SwiftUI

struct CategoryDetailView: View {
    @Environment(SignCatalog.self) private var catalog
    let category: SignCategory

    @State private var searchText = ""

    private var allSigns: [Sign] {
        catalog.signs(in: category)
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
                title: "\(category.title) (\(allSigns.count))",
                showsBackButton: true
            )

            searchField
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Theme.screenBackground)

            List(filteredSigns) { sign in
                NavigationLink(value: sign) {
                    HStack(spacing: 16) {
                        SignImageView(sign: sign, compact: true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sign.code)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text(sign.name)
                                .font(.body.weight(.medium))
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
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .appListSurface()
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
        .navigationDestination(for: Sign.self) { sign in
            StudyCardView(signs: filteredSigns, startIndex: filteredSigns.firstIndex(of: sign) ?? 0)
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search by code or name", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
