//
//  TestsTabView.swift
//  Trafikal
//

import SwiftUI

private enum TestTabMode: String, CaseIterable, Identifiable {
    case signs
    case questions

    var id: String { rawValue }
}

private enum TestQuestionCount: Int, CaseIterable {
    case ten = 10
    case thirty = 30
    case sixtyFive = 65
}

struct TestsTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(SignCatalog.self) private var signCatalog
    @Environment(TheoryQuestionCatalog.self) private var theoryCatalog
    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(TestSessionStore.self) private var signSessionStore
    @Environment(TheoryQuestionSessionStore.self) private var questionSessionStore

    @State private var mode: TestTabMode = .signs
    @State private var selectedQuestionCount: TestQuestionCount = .ten
    @State private var showSignSession = false
    @State private var showQuestionSession = false
    @State private var showHistory = false

    private let buttonWidth: CGFloat = 280
    private let accentBlue = Color.accentColor
    private let heroGray = Color(.darkGray)

    var body: some View {
        Group {
            if showSignSession {
                TestSessionView(isPresented: $showSignSession)
            } else if showQuestionSession {
                TheoryQuestionSessionView(isPresented: $showQuestionSession)
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
            dismissFinishedSessionsIfNeeded()
        }
        .onChange(of: showSignSession) { _, isShowing in
            if !isShowing {
                dismissFinishedSignSessionIfNeeded()
            }
        }
        .onChange(of: showQuestionSession) { _, isShowing in
            if !isShowing {
                dismissFinishedQuestionSessionIfNeeded()
            }
        }
        .onChange(of: mode) { _, _ in
            resumeSessionIfNeeded()
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView(initialFilter: mode == .signs ? .signs : .questions)
        }
    }

    private var startScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 28)

                Text(l10n.text(.testsTitle))
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(heroGray)

                modePicker
                    .padding(.top, 20)
                    .padding(.bottom, 25    )
                    .padding(.horizontal, 36)

                instructionsText
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)

                VStack(spacing: 12) {
                    questionCountPicker
                        .padding(.bottom, 12)

                    Button {
                        startNewQuiz()
                    } label: {
                        Text(startButtonTitle)
                    }
                    .buttonStyle(PrimaryActionButtonStyle(width: buttonWidth))

                    Button {
                        showHistory = true
                    } label: {
                        Text(l10n.text(.signsPreviousResults))
                    }
                    .buttonStyle(SecondaryActionButtonStyle(width: buttonWidth, tint: accentBlue))
                }
                .padding(.top, 25)

                if let last = historyStore.lastEntry(kind: historyKind) {
                    lastQuizSection(entry: last)
                        .padding(.top, 44)
                }

                Spacer(minLength: 32)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var modePicker: some View {
        Picker("", selection: $mode) {
            Text(l10n.text(.tabSigns)).tag(TestTabMode.signs)
            Text(l10n.text(.tabQuestions)).tag(TestTabMode.questions)
        }
        .pickerStyle(.segmented)
    }

    private var questionCountPicker: some View {
        HStack(spacing: 10) {
            ForEach(TestQuestionCount.allCases, id: \.rawValue) { count in
                let isSelected = selectedQuestionCount == count
                Button {
                    selectedQuestionCount = count
                } label: {
                    Text("\(count.rawValue)")
                        .font(.subheadline.weight(.semibold))
                        .frame(minWidth: 48)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .background(
                            isSelected ? accentBlue : Color(.systemGray5),
                            in: RoundedRectangle(
                                cornerRadius: ListCardStyle.cornerRadius,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var instructionsText: Text {
        let count = selectedQuestionCount.rawValue
        let markdown: String
        switch mode {
        case .signs:
            markdown = l10n.text(.signsInstructions, count)
        case .questions:
            markdown = l10n.text(.questionsInstructions, count)
        }

        if let attributed = try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(attributed)
        }

        return Text(markdown)
    }

    private var startButtonTitle: String {
        switch mode {
        case .signs:
            l10n.text(.signsStartNew)
        case .questions:
            l10n.text(.questionsStartNew)
        }
    }

    private var historyKind: QuizHistoryKind {
        mode == .signs ? .signs : .questions
    }

    private func startNewQuiz() {
        let count = selectedQuestionCount.rawValue
        switch mode {
        case .signs:
            signSessionStore.startTest(catalog: signCatalog, questionCount: count)
            showSignSession = true
        case .questions:
            questionSessionStore.startSession(catalog: theoryCatalog, questionCount: count)
            showQuestionSession = true
        }
    }

    private func resumeSessionIfNeeded() {
        dismissFinishedSessionsIfNeeded()

        switch mode {
        case .signs:
            showQuestionSession = false
            if signSessionStore.hasResumableSession {
                showSignSession = true
            } else {
                showSignSession = false
            }
        case .questions:
            showSignSession = false
            if questionSessionStore.hasResumableSession {
                showQuestionSession = true
            } else {
                showQuestionSession = false
            }
        }
    }

    private func dismissFinishedSessionsIfNeeded() {
        dismissFinishedSignSessionIfNeeded()
        dismissFinishedQuestionSessionIfNeeded()
    }

    private func dismissFinishedSignSessionIfNeeded() {
        guard signSessionStore.finished else { return }
        signSessionStore.clear()
        showSignSession = false
    }

    private func dismissFinishedQuestionSessionIfNeeded() {
        guard questionSessionStore.finished else { return }
        questionSessionStore.clear()
        showQuestionSession = false
    }

    private func lastQuizSection(entry: TestHistoryEntry) -> some View {
        VStack(spacing: 18) {
            Text(lastQuizLabel(for: entry.date))
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)

            TestScoreRingView(percent: entry.percentCorrect)
                .padding(.top, 28)
        }
    }

    private func lastQuizLabel(for date: Date) -> String {
        switch mode {
        case .signs:
            l10n.text(.signsYourLastQuiz, formattedDate(date))
        case .questions:
            l10n.text(.questionsYourLastQuiz, formattedDate(date))
        }
    }

    private func formattedDate(_ date: Date) -> String {
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
    .environment(TheoryQuestionCatalog.shared)
    .environment(TestHistoryStore.shared)
    .environment(TestSessionStore.shared)
    .environment(TheoryQuestionSessionStore.shared)
    .environment(LocalizationManager.shared)
}
