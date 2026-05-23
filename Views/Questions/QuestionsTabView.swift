//
//  QuestionsTabView.swift
//  Trafikal
//

import SwiftUI

struct QuestionsTabView: View {
    @Environment(TheoryQuestionCatalog.self) private var catalog
    @Environment(TheoryQuestionSessionStore.self) private var sessionStore

    @State private var showSession = false

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
    }

    private var startScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 28)

                Text("Questions")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(heroGray)

                heroIcon
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                Text(instructionText)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)

                Button {
                    sessionStore.startSession(catalog: catalog)
                    showSession = true
                } label: {
                    Text("Start new test")
                }
                .buttonStyle(PrimaryActionButtonStyle(width: buttonWidth))
                .padding(.top, 28)

                Spacer(minLength: 32)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func resumeSessionIfNeeded() {
        if sessionStore.finished {
            sessionStore.clear()
        } else if sessionStore.hasResumableSession {
            showSession = true
        }
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

    private var instructionText: String {
        "Answer 10 random theory questions.\nCheck your result after each answer.\nGood luck!"
    }
}

#Preview {
    NavigationStack {
        QuestionsTabView()
    }
    .environment(TheoryQuestionCatalog.shared)
    .environment(TheoryQuestionSessionStore.shared)
}
