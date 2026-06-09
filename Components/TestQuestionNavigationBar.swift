//
//  TestQuestionNavigationBar.swift
//  Trafikal
//

import SwiftUI

struct TestSessionProgressHeader: View {
    let currentIndex: Int
    let totalCount: Int

    var body: some View {
        VStack(spacing: 6) {
            ProgressView(
                value: Double(currentIndex + 1),
                total: Double(totalCount)
            )
            Text("\(currentIndex + 1)/\(totalCount)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Theme.screenBackground)
    }
}

struct TestQuestionNavigationBar: View {
    @Environment(LocalizationManager.self) private var l10n

    let canGoBack: Bool
    let canGoForward: Bool
    let forwardTitle: String
    let onBack: () -> Void
    let onForward: () -> Void

    var body: some View {
        BrowseNavigationBar(
            previousTitle: l10n.text(.studyPrevious),
            nextTitle: forwardTitle,
            canGoPrevious: canGoBack,
            canGoNext: canGoForward,
            onPrevious: onBack,
            onNext: onForward
        )
    }
}
