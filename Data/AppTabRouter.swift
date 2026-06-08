//
//  AppTabRouter.swift
//  Trafikal
//

import Foundation

enum AppMainTab: Int {
    case home = 0
    case practice = 1
    case goal = 2
    case tests = 3
    case settings = 4
}

enum AppPracticeMode: String, Sendable {
    case signs
    case questions
}

struct PendingTestLaunch: Equatable, Sendable {
    enum Kind: Sendable {
        case signs
        case questions
    }

    let kind: Kind
    let questionCount: Int
}

@MainActor
@Observable
final class AppTabRouter {
    static let shared = AppTabRouter()

    var selectedTab: Int = AppMainTab.home.rawValue
    var pendingTestLaunch: PendingTestLaunch?
    var pendingPracticeMode: AppPracticeMode?

    private init() {}

    func openSignTest(questionCount: Int = 10) {
        selectedTab = AppMainTab.tests.rawValue
        pendingTestLaunch = PendingTestLaunch(kind: .signs, questionCount: questionCount)
    }

    func openQuestionTest(questionCount: Int = 10) {
        selectedTab = AppMainTab.tests.rawValue
        pendingTestLaunch = PendingTestLaunch(kind: .questions, questionCount: questionCount)
    }

    func openPracticeSigns() {
        selectedTab = AppMainTab.practice.rawValue
        pendingPracticeMode = .signs
    }

    func openPracticeQuestions() {
        selectedTab = AppMainTab.practice.rawValue
        pendingPracticeMode = .questions
    }

    func consumePendingTestLaunch() -> PendingTestLaunch? {
        defer { pendingTestLaunch = nil }
        return pendingTestLaunch
    }

    func consumePendingPracticeMode() -> AppPracticeMode? {
        defer { pendingPracticeMode = nil }
        return pendingPracticeMode
    }
}
