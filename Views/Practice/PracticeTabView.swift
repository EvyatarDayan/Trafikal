//
//  PracticeTabView.swift
//  Trafikal
//

import SwiftUI

private enum PracticeTabMode: String, CaseIterable, Identifiable {
    case signs
    case questions

    var id: String { rawValue }
}

struct PracticeTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(AppTabRouter.self) private var tabRouter

    @State private var mode: PracticeTabMode = .signs

    private let heroGray = Color(.darkGray)

    var body: some View {
        VStack(spacing: 0) {
            Text(l10n.text(.practiceTitle))
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(heroGray)
                .frame(maxWidth: .infinity)
                .padding(.top, 28)

            modePicker
                .padding(.top, 20)
                .padding(.bottom, 8)
                .padding(.horizontal, 36)
                .background(Theme.screenBackground)

            Group {
                switch mode {
                case .signs:
                    SignsTabRoot(showsTitleBar: false)
                case .questions:
                    QuestionsTabRoot(showsTitleBar: false)
                }
            }
            .id(mode)
        }
        .appRootScreen()
        .appScreenBackground()
        .onAppear {
            handlePendingPracticeModeIfNeeded()
        }
        .onChange(of: tabRouter.pendingPracticeMode) { _, pendingMode in
            guard pendingMode != nil else { return }
            handlePendingPracticeModeIfNeeded()
        }
        .onChange(of: tabRouter.selectedTab) { _, selectedTab in
            guard selectedTab == AppMainTab.practice.rawValue else { return }
            handlePendingPracticeModeIfNeeded()
        }
    }

    @discardableResult
    private func handlePendingPracticeModeIfNeeded() -> Bool {
        guard tabRouter.selectedTab == AppMainTab.practice.rawValue,
              let pendingMode = tabRouter.consumePendingPracticeMode() else {
            return false
        }

        switch pendingMode {
        case .signs:
            mode = .signs
        case .questions:
            mode = .questions
        }

        return true
    }

    private var modePicker: some View {
        Picker("", selection: $mode) {
            Text(l10n.text(.tabSigns)).tag(PracticeTabMode.signs)
            Text(l10n.text(.tabQuestions)).tag(PracticeTabMode.questions)
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    NavigationStack {
        PracticeTabView()
    }
    .environment(SignCatalog.shared)
    .environment(TheoryQuestionCatalog.shared)
    .environment(FavoritesStore.shared)
    .environment(AppTabRouter.shared)
    .environment(LocalizationManager.shared)
}
