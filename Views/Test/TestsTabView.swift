//
//  TestsTabView.swift
//  Trafikal
//

import SwiftUI

struct TestsTabView: View {
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
        .navigationDestination(isPresented: $showHistory) {
            HistoryView()
        }
    }

    private var startScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 28)

                Text("Test")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(heroGray)

                testHeroIcon
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                Text(instructionText)
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
                        Text("Start new test")
                    }
                    .buttonStyle(PrimaryActionButtonStyle(width: buttonWidth))

                    Button {
                        showHistory = true
                    } label: {
                        Text("Previous tests")
                    }
                    .buttonStyle(SecondaryActionButtonStyle(width: buttonWidth, tint: accentBlue))
                }
                .padding(.top, 28)

                if let last = historyStore.lastEntry {
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
            sessionStore.clear()
        } else if sessionStore.hasResumableSession {
            showTestSession = true
        }
    }

    private var testHeroIcon: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 76, weight: .light))
                .foregroundStyle(heroGray)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(heroGray)
                .background(Circle().fill(Color(.systemGroupedBackground)).padding(2))
                .offset(x: 10, y: 10)
        }
    }

    private var instructionText: String {
        "Answer 10 random sign questions.\nCheck your result after each answer.\nGood luck!"
    }

    private func lastTestSection(entry: TestHistoryEntry) -> some View {
        VStack(spacing: 18) {
            Text("Your last test \(formattedTestDate(entry.date))")
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

            TestScoreRingView(percent: entry.percentCorrect)
        }
    }

    private func formattedTestDate(_ date: Date) -> String {
        let formatter = DateFormatter()
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
}
