//
//  TestHistoryStore.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class TestHistoryStore {
    static let shared = TestHistoryStore()

    private(set) var entries: [TestHistoryEntry] = []

    private let storageKey = "trafikal.testHistory"

    private init() {
        load()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            entries = []
            return
        }
        do {
            entries = try JSONDecoder().decode([TestHistoryEntry].self, from: data)
                .sorted { $0.date > $1.date }
        } catch {
            entries = []
        }
    }

    var testsCompleted: Int { entries.count }

    func testsCompleted(kind: QuizHistoryKind) -> Int {
        entries.filter { $0.kind == kind }.count
    }

    func lastEntry(kind: QuizHistoryKind? = nil) -> TestHistoryEntry? {
        if let kind {
            return entries.first { $0.kind == kind }
        }
        return entries.first
    }

    func entries(filter: HistoryFilter) -> [TestHistoryEntry] {
        entries.filter { filter.matches($0.kind) }
    }

    /// Aggregated scores from the most recent completed tests (newest first).
    func recentAggregate(limit: Int = 10, kind: QuizHistoryKind? = nil) -> RecentTestAggregate? {
        let pool: [TestHistoryEntry]
        if let kind {
            pool = entries.filter { $0.kind == kind }
        } else {
            pool = entries
        }
        let recent = Array(pool.prefix(limit))
        guard !recent.isEmpty else { return nil }

        let correct = recent.reduce(0) { $0 + $1.score }
        let totalQuestions = recent.reduce(0) { $0 + $1.totalQuestions }
        return RecentTestAggregate(
            testCount: recent.count,
            correctCount: correct,
            totalQuestions: totalQuestions
        )
    }

    /// Average percent correct over the most recent entries (up to 5).
    func averagePercentRecent(kind: QuizHistoryKind? = nil) -> Int? {
        recentAggregate(limit: 5, kind: kind)?.averagePercent
    }

    func bestPercent(kind: QuizHistoryKind? = nil) -> Int? {
        let pool: [TestHistoryEntry]
        if let kind {
            pool = entries.filter { $0.kind == kind }
        } else {
            pool = entries
        }
        return pool.map(\.percentCorrect).max()
    }

    func record(score: Int, totalQuestions: Int, kind: QuizHistoryKind) {
        guard totalQuestions > 0 else { return }
        let entry = TestHistoryEntry(score: score, totalQuestions: totalQuestions, kind: kind)
        entries.insert(entry, at: 0)
        save()
    }

    func clearAll() {
        entries = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Keep in-memory entries if persistence fails.
        }
    }
}
