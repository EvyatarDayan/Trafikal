//
//  SmartQuizGenerator.swift
//  Trafikal
//

import Foundation

enum SmartQuizGenerator {
    /// Max share of a quiz devoted to repeat-review items; the rest explores new material.
    private static let defaultMaxReviewShare = 0.4

    private static let remainderRatios: [(QuestionSelectionPriority, Double)] = [
        (.unseen, 0.70),
        (.learning, 0.30),
        (.mastered, 0.0)
    ]

    private static let fillOrder: [QuestionSelectionPriority] = [
        .needsReview, .unseen, .learning, .mastered
    ]

    /// Builds a quiz that repeats a capped number of missed items, then prioritizes unseen material.
    /// Unseen and learning pools prefer items seen longest ago (or never) for better catalog coverage.
    static func generateSmartQuiz<Item, ID>(
        from items: [Item],
        reviewItemIDs: [ID],
        idFor: (Item) -> ID,
        priorityFor: (ID) -> QuestionSelectionPriority,
        totalItems: Int,
        maxReviewItems: Int? = nil,
        lastSeenAt: ((ID) -> Date?)? = nil
    ) -> [Item] where ID: Hashable {
        guard !items.isEmpty, totalItems > 0 else { return [] }

        let targetCount = min(totalItems, items.count)
        let reviewCap = min(
            reviewItemIDs.count,
            maxReviewItems ?? defaultReviewCap(for: targetCount)
        )
        let cappedReviewIDs = Array(reviewItemIDs.prefix(reviewCap))
        let reviewIDSet = Set(cappedReviewIDs)
        let itemsByID = Dictionary(uniqueKeysWithValues: items.map { (idFor($0), $0) })

        var selected: [Item] = []
        var selectedIDs = Set<ID>()
        selected.reserveCapacity(targetCount)

        // 1. Include the highest-priority missed items, capped so new material still appears.
        for itemID in cappedReviewIDs {
            guard selected.count < targetCount else { break }
            guard let item = itemsByID[itemID] else { continue }
            guard selectedIDs.insert(itemID).inserted else { continue }
            selected.append(item)
        }

        var pools = priorityPools(
            from: items,
            idFor: idFor,
            priorityFor: priorityFor,
            excludingIDs: selectedIDs.union(reviewIDSet),
            lastSeenAt: lastSeenAt
        )

        // 2. Fill the rest with unseen and learning first.
        if selected.count < targetCount {
            let remaining = targetCount - selected.count
            let targets = remainderQuotaTargets(for: remaining)

            for priority in [QuestionSelectionPriority.unseen, .learning, .mastered] {
                appendItems(
                    from: &pools,
                    priority: priority,
                    upTo: targets[priority, default: 0],
                    idFor: idFor,
                    into: &selected,
                    selectedIDs: &selectedIDs
                )
            }
        }

        // 3. Last resort — any priority still left.
        if selected.count < targetCount {
            for priority in fillOrder {
                appendItems(
                    from: &pools,
                    priority: priority,
                    upTo: targetCount - selected.count,
                    idFor: idFor,
                    into: &selected,
                    selectedIDs: &selectedIDs
                )
                if selected.count >= targetCount { break }
            }
        }

        return selected.shuffled()
    }

    static func defaultReviewCap(for targetCount: Int) -> Int {
        max(1, Int((Double(targetCount) * defaultMaxReviewShare).rounded(.down)))
    }

    private static func priorityPools<Item, ID>(
        from items: [Item],
        idFor: (Item) -> ID,
        priorityFor: (ID) -> QuestionSelectionPriority,
        excludingIDs: Set<ID>,
        lastSeenAt: ((ID) -> Date?)? = nil
    ) -> [QuestionSelectionPriority: [Item]] where ID: Hashable {
        var pools = Dictionary(
            uniqueKeysWithValues: QuestionSelectionPriority.allCases.map { ($0, [Item]()) }
        )
        pools.reserveCapacity(QuestionSelectionPriority.allCases.count)

        for item in items where !excludingIDs.contains(idFor(item)) {
            pools[priorityFor(idFor(item)), default: []].append(item)
        }

        for priority in QuestionSelectionPriority.allCases {
            guard var pool = pools[priority], !pool.isEmpty else { continue }

            if let lastSeenAt, priority == .unseen || priority == .learning {
                pool.sort { lhs, rhs in
                    prefersEarlierCoverage(
                        idFor(lhs),
                        idFor(rhs),
                        lastSeenAt: lastSeenAt
                    )
                }
            } else {
                pool.shuffle()
            }

            pools[priority] = pool
        }

        return pools
    }

    /// `true` when `left` should appear before `right` (never-seen first, then oldest).
    private static func prefersEarlierCoverage<ID: Hashable>(
        _ left: ID,
        _ right: ID,
        lastSeenAt: (ID) -> Date?
    ) -> Bool {
        let leftDate = lastSeenAt(left)
        let rightDate = lastSeenAt(right)

        switch (leftDate, rightDate) {
        case (nil, nil):
            return false
        case (nil, _):
            return true
        case (_, nil):
            return false
        case let (left?, right?):
            return left < right
        }
    }

    private static func remainderQuotaTargets(for count: Int) -> [QuestionSelectionPriority: Int] {
        let unseen = Int((Double(count) * remainderRatios[0].1).rounded())
        let learning = max(0, count - unseen)

        return [
            .unseen: unseen,
            .learning: learning,
            .mastered: 0
        ]
    }

    private static func appendItems<Item, ID>(
        from pools: inout [QuestionSelectionPriority: [Item]],
        priority: QuestionSelectionPriority,
        upTo limit: Int,
        idFor: (Item) -> ID,
        into selected: inout [Item],
        selectedIDs: inout Set<ID>
    ) where ID: Hashable {
        guard limit > 0 else { return }

        let candidates = pools[priority, default: []]
        guard !candidates.isEmpty else { return }

        var picked = 0
        var remaining: [Item] = []
        remaining.reserveCapacity(candidates.count)

        for item in candidates {
            guard picked < limit else {
                remaining.append(item)
                continue
            }

            if selectedIDs.insert(idFor(item)).inserted {
                selected.append(item)
                picked += 1
            }
        }

        pools[priority] = remaining
    }
}
