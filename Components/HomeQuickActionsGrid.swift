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
    let onSimulationTest: () -> Void
    let onPracticeSigns: () -> Void
    let onPracticeQuestions: () -> Void

    private let tileAspectRatio: CGFloat = 1.55
    private let columnSpacing: CGFloat = 12

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    @State private var tileHeight: CGFloat = 88

    private let testsTabIcon = "list.clipboard.fill"
    private let practiceTabIcon = "books.vertical.fill"

    var body: some View {
        VStack(spacing: columnSpacing) {
            LazyVGrid(columns: columns, spacing: columnSpacing) {
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

            simulationButton
        }
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        updateTileHeight(for: geometry.size.width)
                    }
                    .onChange(of: geometry.size.width) { _, width in
                        updateTileHeight(for: width)
                    }
            }
        }
    }

    private var simulationButton: some View {
        Button(action: onSimulationTest) {
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.appBlue)

                Text(l10n.text(.homeShortcutSimulationTest))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .background(Theme.appBlue.opacity(0.1), in: RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(colorScheme == .light ? 0.06 : 0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .frame(height: tileHeight)
        .accessibilityLabel(l10n.text(.homeShortcutSimulationTest))
    }

    private func updateTileHeight(for width: CGFloat) {
        let columnWidth = (width - columnSpacing) / 2
        tileHeight = columnWidth / tileAspectRatio
    }

    private func actionButton(
        icon: String,
        title: String,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.accentColor)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .background(background, in: RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(colorScheme == .light ? 0.06 : 0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(tileAspectRatio, contentMode: .fit)
        .accessibilityLabel(title)
    }
}
