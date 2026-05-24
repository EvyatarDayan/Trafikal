//
//  CategoryListView.swift
//  Trafikal
//

import SwiftUI

struct CategoryListView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(SignCatalog.self) private var catalog

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: l10n.text(.categoriesTitle))

            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        Spacer(minLength: 0)
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(SignCategory.allCases) { category in
                                let count = catalog.count(for: category)
                                if count > 0 {
                                    NavigationLink(value: category) {
                                        CategoryCard(category: category, count: count, l10n: l10n)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .appRootScreen()
        .appScreenBackground()
        .navigationDestination(for: SignCategory.self) { category in
            CategoryDetailView(category: category)
        }
    }
}

private struct CategoryCard: View {
    let category: SignCategory
    let count: Int
    let l10n: LocalizationManager

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.systemImage)
                .font(.title2)
                .foregroundStyle(category.accentColor)

            VStack(spacing: 4) {
                Text(category.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                Text(category.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 0)

            Text(l10n.text(.categoriesSignCount, count))
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(category.accentColor, lineWidth: 10)
        }
    }
}
