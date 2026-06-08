//
//  HomeQuickActionsGrid.swift
//  Trafikal
//

import SwiftUI

struct HomeQuickActionsGrid: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme

    let onSignTest: () -> Void
    let onQuestionTest: () -> Void
    let onPracticeSigns: () -> Void
    let onPracticeQuestions: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let testsTabIcon = "list.clipboard.fill"
    private let practiceTabIcon = "books.vertical.fill"

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            actionButton(
                icon: testsTabIcon,
                title: l10n.text(.homeShortcutSignTest),
                background: Color.green.opacity(0.1),
                action: onSignTest
            )
            actionButton(
                icon: testsTabIcon,
                title: l10n.text(.homeShortcutQuestionTest),
                background: Color.green.opacity(0.1),
                action: onQuestionTest
            )
            actionButton(
                icon: practiceTabIcon,
                title: l10n.text(.homeShortcutPracticeSigns),
                background: Color.purple.opacity(0.1),
                action: onPracticeSigns
            )
            actionButton(
                icon: practiceTabIcon,
                title: l10n.text(.homeShortcutPracticeQuestions),
                background: Color.purple.opacity(0.1),
                action: onPracticeQuestions
            )
        }
    }

    private func actionButton(
        icon: String,
        title: String,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.accentColor)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 14)
            .background(background, in: RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(colorScheme == .light ? 0.06 : 0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(title)
    }
}
