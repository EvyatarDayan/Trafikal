//
//  QuizDistractorPicker.swift
//  Trafikal
//

import Foundation

enum QuizDistractorPicker {
    private static let keywordStoplist: Set<String> = [
        "sign", "road", "traffic", "swedish", "warning", "mandatory", "information",
        "prohibition", "priority", "vehicles", "vehicle", "drivers", "driver",
        "indicates", "adjust", "speed", "prepared", "hazard", "ahead", "area",
        "follow", "rule", "rules", "must", "this", "same", "other", "than",
    ]

    /// Picks plausible wrong answers: same category first, ranked by similarity.
    static func selectWrongAnswers(correct: Sign, from pool: [Sign], count: Int = 3) -> [Sign] {
        guard count > 0 else { return [] }

        var usedNames = Set([correct.name])
        var selected: [Sign] = []
        let candidates = pool.filter { $0.id != correct.id }
        let sameCategory = candidates.filter { $0.category == correct.category }

        addPicks(from: sameCategory, correct: correct, need: count - selected.count, usedNames: &usedNames, selected: &selected, smart: true)
        addPicks(from: candidates, correct: correct, need: count - selected.count, usedNames: &usedNames, selected: &selected, smart: true)
        addPicks(from: candidates, correct: correct, need: count - selected.count, usedNames: &usedNames, selected: &selected, smart: false)

        return selected
    }

    private static func addPicks(
        from source: [Sign],
        correct: Sign,
        need: Int,
        usedNames: inout Set<String>,
        selected: inout [Sign],
        smart: Bool
    ) {
        guard need > 0 else { return }

        let available = source.filter { !usedNames.contains($0.name) }
        let ordered: [Sign] = if smart {
            Array(ranked(correct: correct, candidates: available).prefix(max(6, need * 2))).shuffled()
        } else {
            available.shuffled()
        }

        var remaining = need
        for sign in ordered {
            guard remaining > 0 else { break }
            guard !usedNames.contains(sign.name) else { continue }
            usedNames.insert(sign.name)
            selected.append(sign)
            remaining -= 1
        }
    }

    private static func ranked(correct: Sign, candidates: [Sign]) -> [Sign] {
        candidates
            .map { ($0, similarityScore(correct: correct, candidate: $0)) }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                return lhs.0.name.localizedCaseInsensitiveCompare(rhs.0.name) == .orderedAscending
            }
            .map(\.0)
    }

    static func similarityScore(correct: Sign, candidate: Sign) -> Int {
        var score = 0

        if baseCode(correct.code) == baseCode(candidate.code) {
            score += 3
        }

        if correct.category == candidate.category {
            score += 2
        }

        let sharedKeywords = significantKeywords(for: correct).intersection(significantKeywords(for: candidate))
        score += sharedKeywords.count * 2

        let sharedNameWords = significantNameWords(in: correct.name).intersection(significantNameWords(in: candidate.name))
        score += sharedNameWords.count

        if correct.relatedCodes.contains(candidate.code) || candidate.relatedCodes.contains(correct.code) {
            score += 1
        }

        return score
    }

    static func baseCode(_ code: String) -> String {
        guard let match = code.wholeMatch(of: /^([A-Z]+)(\d+[a-z]?)/) else { return code }
        return String(match.1) + String(match.2)
    }

    private static func significantKeywords(for sign: Sign) -> Set<String> {
        Set(
            sign.keywords
                .map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { word in
                    word.count >= 3 && !keywordStoplist.contains(word)
                }
        )
    }

    private static func significantNameWords(in name: String) -> Set<String> {
        Set(
            name
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { word in
                    word.count >= 4 && !keywordStoplist.contains(word)
                }
        )
    }
}
