//
//  TestsTabView.swift
//  Trafikal
//

import SwiftUI

struct TestsTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(SignCatalog.self) private var catalog
    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(TestSessionStore.self) private var sessionStore

    @State private var showTestSession = false
    @State private var showHistory = false

    private let buttonWidth: CGFloat = 280
    private let accentBlue = Color.accentColor
    private let heroGray = Color(.darkGray)

    var body: some View {
        Group {
            if showTestSession {
                TestSessionView(isPresented: $showTestSession)
            } else {
                startScreen
            }
        }
        .appRootScreen()
        .appScreenBackground()
        .onAppear {
            resumeSessionIfNeeded()
        }
        .onDisappear {
            dismissFinishedSessionIfNeeded()
        }
        .onChange(of: showTestSession) { _, isShowing in
            if !isShowing {
                dismissFinishedSessionIfNeeded()
            }
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView(initialFilter: .signs)
        }
    }

    private var startScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 28)

                Text(l10n.text(.signsTitle))
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(heroGray)

                testHeroIcon
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                Text(l10n.text(.signsInstructions))
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)

                VStack(spacing: 12) {
                    Button {
                        sessionStore.startTest(catalog: catalog)
                        showTestSession = true
                    } label: {
                        Text(l10n.text(.signsStartNew))
                    }
                    .buttonStyle(PrimaryActionButtonStyle(width: buttonWidth))

                    Button {
                        showHistory = true
                    } label: {
                        Text(l10n.text(.signsPreviousResults))
                    }
                    .buttonStyle(SecondaryActionButtonStyle(width: buttonWidth, tint: accentBlue))
                }
                .padding(.top, 28)

                if let last = historyStore.lastEntry(kind: .signs) {
                    lastTestSection(entry: last)
                        .padding(.top, 44)
                }

                Spacer(minLength: 32)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func resumeSessionIfNeeded() {
        if sessionStore.finished {
            dismissFinishedSessionIfNeeded()
        } else if sessionStore.hasResumableSession {
            showTestSession = true
        } else {
            showTestSession = false
        }
    }

    private func dismissFinishedSessionIfNeeded() {
        guard sessionStore.finished else { return }
        sessionStore.clear()
        showTestSession = false
    }

    private var testHeroIcon: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "signpost.right")
                .font(.system(size: 76, weight: .light))
                .foregroundStyle(heroGray)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(heroGray)
                .background(Circle().fill(Color(.systemGroupedBackground)).padding(2))
                .offset(x: 10, y: 10)
        }
    }

    private func lastTestSection(entry: TestHistoryEntry) -> some View {
        VStack(spacing: 18) {
            Text(l10n.text(.signsYourLastQuiz, formattedTestDate(entry.date)))
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

            TestScoreRingView(percent: entry.percentCorrect)
        }
    }

    private func formattedTestDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = l10n.locale
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        TestsTabView()
    }
    .environment(SignCatalog.shared)
    .environment(TestHistoryStore.shared)
    .environment(TestSessionStore.shared)
    .environment(LocalizationManager.shared)
}
