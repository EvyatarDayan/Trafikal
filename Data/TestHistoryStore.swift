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

    var lastEntry: TestHistoryEntry? { entries.first }

    /// Average percent correct over the most recent tests (up to 5).
    var averagePercentRecent: Int? {
        let recent = Array(entries.prefix(5))
        guard !recent.isEmpty else { return nil }
        let sum = recent.reduce(0) { $0 + $1.percentCorrect }
        return sum / recent.count
    }

    var bestPercent: Int? {
        entries.map(\.percentCorrect).max()
    }

    func record(score: Int, totalQuestions: Int) {
        guard totalQuestions > 0 else { return }
        let entry = TestHistoryEntry(score: score, totalQuestions: totalQuestions)
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
