//
//  SignProgressStore.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class SignProgressStore {
    static let shared = SignProgressStore()

    private(set) var progressBySignCode: [String: SignProgress] = [:]

    private let storageKey = "trafikal.signProgress"

    private init() {
        load()
    }

    func progress(for signCode: String) -> SignProgress {
        progressBySignCode[signCode] ?? SignProgress(signCode: signCode)
    }

    func signCodesNeedingReview() -> [String] {
        progressBySignCode.values
            .filter(needsReview(_:))
            .sorted { lhs, rhs in
                if lhs.wrongCount != rhs.wrongCount { return lhs.wrongCount > rhs.wrongCount }
                let leftDate = lhs.lastAnsweredAt ?? .distantPast
                let rightDate = rhs.lastAnsweredAt ?? .distantPast
                return leftDate < rightDate
            }
            .map(\.signCode)
    }

    func selectionPriority(for signCode: String) -> QuestionSelectionPriority {
        guard let progress = progressBySignCode[signCode] else {
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

    func recordAnswer(signCode: String, correct: Bool) {
        var progress = progress(for: signCode)

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
        progressBySignCode[signCode] = progress
        save()
    }

    private func needsReview(_ progress: SignProgress) -> Bool {
        if progress.lastAnswerWasCorrect == false {
            return true
        }

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
            progressBySignCode = [:]
            return
        }

        do {
            let decoded = try JSONDecoder().decode([SignProgress].self, from: data)
            progressBySignCode = Dictionary(uniqueKeysWithValues: decoded.map { ($0.signCode, migrateIfNeeded($0)) })
        } catch {
            progressBySignCode = [:]
        }
    }

    private func migrateIfNeeded(_ progress: SignProgress) -> SignProgress {
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
            let payload = Array(progressBySignCode.values)
            let data = try JSONEncoder().encode(payload)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Keep in-memory progress if persistence fails.
        }
    }
}
