//
//  TheoryQuestionProgressStore.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class TheoryQuestionProgressStore {
    static let shared = TheoryQuestionProgressStore()

    private(set) var progressByQuestionID: [Int: TheoryQuestionProgress] = [:]

    private let storageKey = "trafikal.theoryQuestionProgress"

    private init() {
        load()
    }

    func bucket(for questionID: Int) -> QuestionBucket? {
        progressByQuestionID[questionID]?.bucket
    }

    func progress(for questionID: Int) -> TheoryQuestionProgress {
        progressByQuestionID[questionID] ?? TheoryQuestionProgress(questionID: questionID)
    }

    /// Question IDs that should repeat because the last attempt was wrong.
    func questionIDsNeedingReview() -> [Int] {
        progressByQuestionID.values
            .filter(needsReview(_:))
            .sorted { lhs, rhs in
                if lhs.wrongCount != rhs.wrongCount { return lhs.wrongCount > rhs.wrongCount }
                let leftDate = lhs.lastAnsweredAt ?? .distantPast
                let rightDate = rhs.lastAnsweredAt ?? .distantPast
                return leftDate < rightDate
            }
            .map(\.questionID)
    }

    /// How urgently a missed question should reappear (higher = pick first).
    func reviewWeight(for questionID: Int) -> Int {
        guard let progress = progressByQuestionID[questionID], needsReview(progress) else { return 0 }
        return progress.wrongCount * 10 + max(0, 2 - progress.correctStreak)
    }

    func selectionPriority(for questionID: Int) -> QuestionSelectionPriority {
        guard let progress = progressByQuestionID[questionID] else {
            return .unseen
        }

        if needsReview(progress) {
            return .needsReview
        }

        if progress.correctStreak >= 2 {
            return .mastered
        }

        if progress.correctStreak == 1 {
            return .learning
        }

        return .unseen
    }

    func recordAnswer(questionID: Int, correct: Bool) {
        var progress = progress(for: questionID)

        progress.lastAnswerWasCorrect = correct

        if correct {
            progress.correctStreak += 1
            progress.bucket.applyCorrectAnswer()
        } else {
            progress.wrongCount += 1
            progress.correctStreak = 0
            progress.bucket.applyWrongAnswer()
        }

        progress.lastAnsweredAt = Date()
        progressByQuestionID[questionID] = progress
        save()
    }

    func questions(in targetBucket: QuestionBucket, from catalog: TheoryQuestionCatalog) -> [TheoryQuestion] {
        catalog.questions.filter { progressByQuestionID[$0.id]?.bucket == targetBucket }
    }

    private func needsReview(_ progress: TheoryQuestionProgress) -> Bool {
        if progress.lastAnswerWasCorrect == false {
            return true
        }

        // Legacy records saved before `lastAnswerWasCorrect` existed.
        if progress.wrongCount > 0, progress.correctStreak < 2 {
            return true
        }

        if progress.bucket == .new,
           progress.lastAnsweredAt != nil,
           progress.correctStreak == 0,
           progress.wrongCount > 0 {
            return true
        }

        return false
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            progressByQuestionID = [:]
            return
        }

        do {
            let decoded = try JSONDecoder().decode([TheoryQuestionProgress].self, from: data)
            progressByQuestionID = Dictionary(uniqueKeysWithValues: decoded.map { ($0.questionID, migrateIfNeeded($0)) })
        } catch {
            progressByQuestionID = [:]
        }
    }

    /// Back-fill fields for progress saved before review tracking existed.
    private func migrateIfNeeded(_ progress: TheoryQuestionProgress) -> TheoryQuestionProgress {
        var migrated = progress

        if migrated.lastAnswerWasCorrect == nil {
            switch migrated.bucket {
            case .new where migrated.lastAnsweredAt != nil:
                migrated.lastAnswerWasCorrect = false
                if migrated.wrongCount == 0 { migrated.wrongCount = 1 }
            case .learning:
                migrated.lastAnswerWasCorrect = true
                if migrated.correctStreak == 0 { migrated.correctStreak = 1 }
            case .mastered:
                migrated.lastAnswerWasCorrect = true
                if migrated.correctStreak == 0 { migrated.correctStreak = 2 }
            default:
                break
            }
        }

        if migrated.wrongCount == 0, migrated.correctStreak == 0 {
            switch migrated.bucket {
            case .new where migrated.lastAnsweredAt != nil:
                migrated.wrongCount = 1
            case .learning:
                migrated.correctStreak = 1
            case .mastered:
                migrated.correctStreak = 2
            default:
                break
            }
        }

        return migrated
    }

    private func save() {
        do {
            let payload = Array(progressByQuestionID.values)
            let data = try JSONEncoder().encode(payload)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Keep in-memory progress if persistence fails.
        }
    }
}
