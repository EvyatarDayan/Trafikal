//
//  QuestionsTabView.swift
//  Trafikal
//

import SwiftUI

struct QuestionsTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(TheoryQuestionCatalog.self) private var catalog
    @Environment(TheoryQuestionSessionStore.self) private var sessionStore
    @Environment(TestHistoryStore.self) private var historyStore

    @State private var showSession = false
    @State private var showHistory = false

    private let buttonWidth: CGFloat = 280
    private let accentBlue = Color.accentColor
    private let heroGray = Color(.darkGray)

    var body: some View {
        Group {
            if showSession {
                TheoryQuestionSessionView(isPresented: $showSession)
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
        .onChange(of: showSession) { _, isShowing in
            if !isShowing {
                dismissFinishedSessionIfNeeded()
            }
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView(initialFilter: .questions)
        }
    }

    private var startScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 28)

                Text(l10n.text(.questionsTitle))
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(heroGray)

                heroIcon
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                Text(l10n.text(.questionsInstructions))
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)

                VStack(spacing: 12) {
                    Button {
                        sessionStore.startSession(catalog: catalog)
                        showSession = true
                    } label: {
                        Text(l10n.text(.questionsStartNew))
                    }
                    .buttonStyle(PrimaryActionButtonStyle(width: buttonWidth))

                    Button {
                        showHistory = true
                    } label: {
                        Text(l10n.text(.questionsPreviousResults))
                    }
                    .buttonStyle(SecondaryActionButtonStyle(width: buttonWidth, tint: accentBlue))
                }
                .padding(.top, 28)

                if let last = historyStore.lastEntry(kind: .questions) {
                    lastQuizSection(entry: last)
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
            showSession = true
        } else {
            showSession = false
        }
    }

    private func dismissFinishedSessionIfNeeded() {
        guard sessionStore.finished else { return }
        sessionStore.clear()
        showSession = false
    }

    private func lastQuizSection(entry: TestHistoryEntry) -> some View {
        VStack(spacing: 18) {
            Text(l10n.text(.questionsYourLastQuiz, formattedQuizDate(entry.date)))
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

            TestScoreRingView(percent: entry.percentCorrect)
        }
    }

    private func formattedQuizDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = l10n.locale
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    private var heroIcon: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 76, weight: .light))
                .foregroundStyle(heroGray)

            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(heroGray)
                .background(Circle().fill(Color(.systemGroupedBackground)).padding(2))
                .offset(x: 10, y: 10)
        }
    }
}

#Preview {
    NavigationStack {
        QuestionsTabView()
    }
    .environment(TheoryQuestionCatalog.shared)
    .environment(TheoryQuestionSessionStore.shared)
    .environment(TestHistoryStore.shared)
    .environment(LocalizationManager.shared)
}
