//
//  TestsTabView.swift
//  Trafikal
//

import SwiftUI

private enum TestTabMode: String, CaseIterable, Identifiable {
    case signs
    case questions
    case simulate

    var id: String { rawValue }
}

private enum TestQuestionCount: Int, CaseIterable {
    case ten = 10
    case thirty = 30
    case fifty = 50
}

struct TestsTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(AppTabRouter.self) private var tabRouter
    @Environment(SignCatalog.self) private var signCatalog
    @Environment(TheoryQuestionCatalog.self) private var theoryCatalog
    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(TestSessionStore.self) private var signSessionStore
    @Environment(TheoryQuestionSessionStore.self) private var questionSessionStore
    @Environment(TheoryQuestionProgressStore.self) private var questionProgressStore
    @Environment(SignProgressStore.self) private var signProgressStore
    @Environment(SimulationSessionStore.self) private var simulationSessionStore

    @State private var mode: TestTabMode = .signs
    @State private var selectedQuestionCount: TestQuestionCount = .ten
    @State private var showSignSession = false
    @State private var showQuestionSession = false
    @State private var showSimulationSession = false
    @State private var showHistory = false
    @State private var isHandlingShortcut = false

    private let buttonWidth: CGFloat = 280
    private let accentBlue = Color.accentColor

    var body: some View {
        Group {
            if showSignSession {
                TestSessionView(isPresented: $showSignSession)
            } else if showQuestionSession {
                TheoryQuestionSessionView(isPresented: $showQuestionSession)
            } else if showSimulationSession {
                SimulationSessionView(isPresented: $showSimulationSession)
            } else {
                startScreen
            }
        }
        .appRootScreen()
        .appScreenBackground()
        .onAppear {
            if handlePendingTestLaunchIfNeeded() { return }
            dismissFinishedSessionsIfNeeded()
            restoreInProgressSessionIfNeeded()
        }
        .onChange(of: tabRouter.pendingTestLaunch) { _, launch in
            guard launch != nil else { return }
            handlePendingTestLaunchIfNeeded()
        }
        .onChange(of: tabRouter.selectedTab) { _, selectedTab in
            guard selectedTab == AppMainTab.tests.rawValue else { return }
            handlePendingTestLaunchIfNeeded()
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
        .onChange(of: showSimulationSession) { _, isShowing in
            if !isShowing {
                dismissFinishedSimulationSessionIfNeeded()
            }
        }
        .onChange(of: mode) { _, _ in
            guard !isHandlingShortcut else { return }
            showSignSession = false
            showQuestionSession = false
            showSimulationSession = false
            dismissFinishedSessionsIfNeeded()
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView(initialFilter: historyFilter)
        }
    }

    private var startScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 28)

                Text(l10n.text(.testsTitle))
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Theme.appBlue)

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
                    if mode != .simulate {
                        questionCountPicker
                            .padding(.bottom, 12)
                    }

                    Button {
                        startNewQuiz()
                    } label: {
                        Text(startButtonTitle)
                    }
                    .buttonStyle(PrimaryActionButtonStyle(width: buttonWidth))

                    Button {
                        showHistory = true
                    } label: {
                        Text(previousResultsTitle)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(accentBlue)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .padding(.top, 25)

                lastQuizSection(entry: historyStore.lastEntry(kind: historyKind))
                    .padding(.top, 44)
                    .padding(.horizontal, 36)

                Spacer(minLength: 32)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var modePicker: some View {
        Picker("", selection: $mode) {
            Text(l10n.text(.tabSigns)).tag(TestTabMode.signs)
            Text(l10n.text(.tabQuestions)).tag(TestTabMode.questions)
            Text(l10n.text(.testsTabSimulate)).tag(TestTabMode.simulate)
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
        let markdown: String
        switch mode {
        case .signs:
            markdown = l10n.text(.signsInstructions, selectedQuestionCount.rawValue)
        case .questions:
            markdown = l10n.text(.questionsInstructions, selectedQuestionCount.rawValue)
        case .simulate:
            markdown = l10n.text(.simulationInstructions)
        }

        if var attributed = try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            applyAppBlueToBoldText(&attributed)
            return Text(attributed)
        }

        return Text(markdown)
    }

    private func applyAppBlueToBoldText(_ attributed: inout AttributedString) {
        for run in attributed.runs {
            guard let intent = run.inlinePresentationIntent,
                  intent.contains(.stronglyEmphasized) else { continue }
            attributed[run.range].foregroundColor = Theme.appBlue
        }
    }

    private var startButtonTitle: String {
        switch mode {
        case .signs:
            l10n.text(.signsStartNew)
        case .questions:
            l10n.text(.questionsStartNew)
        case .simulate:
            l10n.text(.simulationStartNew)
        }
    }

    private var previousResultsTitle: String {
        switch mode {
        case .signs:
            l10n.text(.signsPreviousResults)
        case .questions:
            l10n.text(.questionsPreviousResults)
        case .simulate:
            l10n.text(.simulationPreviousResults)
        }
    }

    private var historyKind: QuizHistoryKind {
        switch mode {
        case .signs: .signs
        case .questions: .questions
        case .simulate: .simulation
        }
    }

    private var historyFilter: HistoryFilter {
        switch mode {
        case .signs: .signs
        case .questions: .questions
        case .simulate: .simulation
        }
    }

    private func startNewQuiz() {
        switch mode {
        case .signs:
            startSignTest(questionCount: selectedQuestionCount.rawValue)
        case .questions:
            startQuestionTest(questionCount: selectedQuestionCount.rawValue)
        case .simulate:
            startSimulation()
        }
    }

    @discardableResult
    private func handlePendingTestLaunchIfNeeded() -> Bool {
        guard tabRouter.selectedTab == AppMainTab.tests.rawValue,
              let launch = tabRouter.consumePendingTestLaunch() else {
            return false
        }

        isHandlingShortcut = true
        defer { isHandlingShortcut = false }

        showSignSession = false
        showQuestionSession = false
        showSimulationSession = false
        signSessionStore.clear()
        questionSessionStore.clear()
        simulationSessionStore.clear()

        switch launch.kind {
        case .signs:
            mode = .signs
            selectedQuestionCount = questionCountMatching(launch.questionCount)
            startSignTest(questionCount: launch.questionCount)
        case .questions:
            mode = .questions
            selectedQuestionCount = questionCountMatching(launch.questionCount)
            startQuestionTest(questionCount: launch.questionCount)
        case .simulate:
            mode = .simulate
            startSimulation()
        }

        return true
    }

    private func questionCountMatching(_ count: Int) -> TestQuestionCount {
        TestQuestionCount(rawValue: count) ?? .ten
    }

    private func startSignTest(questionCount: Int) {
        signSessionStore.startTest(
            catalog: signCatalog,
            progressStore: signProgressStore,
            questionCount: questionCount
        )
        showSignSession = true
    }

    private func startQuestionTest(questionCount: Int) {
        questionSessionStore.startSession(
            catalog: theoryCatalog,
            progressStore: questionProgressStore,
            questionCount: questionCount
        )
        showQuestionSession = true
    }

    private func startSimulation() {
        simulationSessionStore.clear()
        simulationSessionStore.startSession(
            signCatalog: signCatalog,
            theoryCatalog: theoryCatalog,
            signProgress: signProgressStore,
            questionProgress: questionProgressStore
        )
        showSimulationSession = true
    }

    private func restoreInProgressSessionIfNeeded() {
        guard !showSignSession, !showQuestionSession, !showSimulationSession else { return }

        switch mode {
        case .signs:
            if signSessionStore.hasResumableSession {
                signSessionStore.ensureProgressStore(signProgressStore)
                showSignSession = true
            }
        case .questions:
            if questionSessionStore.hasResumableSession {
                questionSessionStore.ensureProgressStore(questionProgressStore)
                showQuestionSession = true
            }
        case .simulate:
            if simulationSessionStore.hasResumableSession {
                simulationSessionStore.ensureProgressStores(
                    signProgress: signProgressStore,
                    questionProgress: questionProgressStore
                )
                showSimulationSession = true
            }
        }
    }

    private func dismissFinishedSessionsIfNeeded() {
        dismissFinishedSignSessionIfNeeded()
        dismissFinishedQuestionSessionIfNeeded()
        dismissFinishedSimulationSessionIfNeeded()
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

    private func dismissFinishedSimulationSessionIfNeeded() {
        guard simulationSessionStore.finished else { return }
        simulationSessionStore.clear()
        showSimulationSession = false
    }

    private func lastQuizSection(entry: TestHistoryEntry?) -> some View {
        HomeCard(elevated: true, cornerRadius: 16) {
            VStack(spacing: 18) {
                Text(entry.map { lastQuizLabel(for: $0.date) } ?? l10n.text(.testsYourLastResults))
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                TestResultsPieChart(
                    statisticsCorrect: entry?.score ?? 0,
                    total: entry?.totalQuestions ?? 0
                )
                .frame(maxWidth: .infinity)

                if entry == nil {
                    Text(l10n.text(.testsLastResultsEmpty))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.bottom, 16)
        }
    }

    private func lastQuizLabel(for date: Date) -> String {
        switch mode {
        case .signs:
            l10n.text(.signsYourLastQuiz, formattedDate(date))
        case .questions:
            l10n.text(.questionsYourLastQuiz, formattedDate(date))
        case .simulate:
            l10n.text(.simulationYourLastQuiz, formattedDate(date))
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
    .environment(TheoryQuestionProgressStore.shared)
    .environment(SignProgressStore.shared)
    .environment(SimulationSessionStore.shared)
    .environment(AppTabRouter.shared)
    .environment(LocalizationManager.shared)
}
