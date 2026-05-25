//
//  HomeView.swift
//  Trafikal
//

import SwiftUI

private enum SignListRoute: Hashable {
    case allSigns
    case category(SignCategory)
}

/// Signs tab root content (list of practice options).
struct SignsTabRoot: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(SignCatalog.self) private var catalog

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: l10n.text(.studyTitle))

            ScrollView {
                LazyVStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                    if let error = catalog.loadError {
                        Text(error)
                            .foregroundStyle(.red)
                            .padding(.horizontal, ListCardStyle.horizontalPadding)
                    }

                    sectionHeader(l10n.text(.studyPractice))

                    NavigationLink(value: SignListRoute.allSigns) {
                        allSignsRow
                    }
                    .buttonStyle(.plain)

                    Text(l10n.text(.studyPracticeFooter, catalog.signs.count))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, ListCardStyle.horizontalPadding)
                        .padding(.top, 4)

                    sectionHeader(l10n.text(.studyQuickStart))

                    ForEach(SignCategory.allCases) { category in
                        let items = catalog.signs(in: category)
                        if !items.isEmpty {
                            NavigationLink(value: SignListRoute.category(category)) {
                                categoryRow(
                                    category: category,
                                    count: items.count,
                                    previewSign: categoryPreviewSign(for: category, in: items)
                                )
                            }
                            .buttonStyle(.plain)
                        }
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
        .navigationDestination(for: SignListRoute.self) { route in
            switch route {
            case .allSigns:
                CategoryDetailView(allSigns: ())
            case .category(let category):
                CategoryDetailView(category: category)
            }
        }
    }

    private var allSignsRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Group {
                if let sign = catalog.sign(code: "B4") {
                    SignImageView(sign: sign, maxSide: 44)
                } else {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.title2)
                        .foregroundStyle(.tint)
                }
            }
            .frame(width: 48, height: 48)

            Text(l10n.text(.studyAllSigns))
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            Text("\(catalog.signs.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
    }

    /// First sign in list order, except Supplementary (additional) which uses the second.
    private func categoryPreviewSign(for category: SignCategory, in signs: [Sign]) -> Sign? {
        guard !signs.isEmpty else { return nil }
        if category == .additional, signs.count > 1 {
            return signs[1]
        }
        return signs.first
    }

    private func categoryRow(category: SignCategory, count: Int, previewSign: Sign?) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Group {
                if let previewSign {
                    SignImageView(sign: previewSign, maxSide: 44)
                } else {
                    Image(systemName: category.systemImage)
                        .font(.title2)
                        .foregroundStyle(category.accentColor)
                }
            }
            .frame(width: 48, height: 48)

            Text(category.title)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

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
