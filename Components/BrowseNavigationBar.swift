//
//  BrowseNavigationBar.swift
//  Trafikal
//

import SwiftUI

enum BrowseNavigationBarMetrics {
    static let topPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 20
    static let height: CGFloat = 66
}

struct BrowseNavigationBar: View {
    let previousTitle: String
    let nextTitle: String
    let canGoPrevious: Bool
    let canGoNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 60) {
            browseButton(
                title: previousTitle,
                systemImage: "arrow.left",
                imageTrailing: false,
                isEnabled: canGoPrevious,
                action: onPrevious
            )

            browseButton(
                title: nextTitle,
                systemImage: "arrow.right",
                imageTrailing: true,
                isEnabled: canGoNext,
                action: onNext
            )
        }
        .padding(.top, BrowseNavigationBarMetrics.topPadding)
        .padding(.bottom, BrowseNavigationBarMetrics.bottomPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func browseButton(
        title: String,
        systemImage: String,
        imageTrailing: Bool,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if !imageTrailing {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .bold))
                }

                Text(title)
                    .textCase(.uppercase)

                if imageTrailing {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .bold))
                }
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
        }
        .buttonStyle(BrowseNavigationButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct BrowseNavigationButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Theme.appBlue.opacity(backgroundOpacity(isPressed: configuration.isPressed)),
                in: Capsule()
            )
    }

    private func backgroundOpacity(isPressed: Bool) -> Double {
        guard isEnabled else { return 0.35 }
        return isPressed ? 0.85 : 1
    }
}

extension View {
    /// Reserves the same fixed bottom slot for prev/next navigation as practice detail screens.
    func browseNavigationSlot(background: Color = Theme.screenBackground) -> some View {
        frame(height: BrowseNavigationBarMetrics.height)
            .frame(maxWidth: .infinity)
            .background(background)
    }
}
