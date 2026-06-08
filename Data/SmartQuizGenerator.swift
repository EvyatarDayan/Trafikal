//
//  SmartQuizGenerator.swift
//  Trafikal
//

import Foundation

enum SmartQuizGenerator {
    private static let remainderRatios: [(QuestionSelectionPriority, Double)] = [
        (.unseen, 0.70),
        (.learning, 0.30),
        (.mastered, 0.0)
    ]

    private static let fillOrder: [QuestionSelectionPriority] = [
        .needsReview, .unseen, .learning, .mastered
    ]

    /// Builds a quiz that heavily favors missed items, then unseen, then learning.
    /// Mastered items are only used when nothing else is available.
    static func generateSmartQuiz<Item, ID>(
        from items: [Item],
        reviewItemIDs: [ID],
        idFor: (Item) -> ID,
        priorityFor: (ID) -> QuestionSelectionPriority,
        totalItems: Int
    ) -> [Item] where ID: Hashable {
        guard !items.isEmpty, totalItems > 0 else { return [] }

        let targetCount = min(totalItems, items.count)
        let reviewIDSet = Set(reviewItemIDs)
        let itemsByID = Dictionary(uniqueKeysWithValues: items.map { (idFor($0), $0) })

        var selected: [Item] = []
        var selectedIDs = Set<ID>()
        selected.reserveCapacity(targetCount)

        // 1. Always include missed items first, in priority order.
        for itemID in reviewItemIDs {
            guard selected.count < targetCount else { break }
            guard let item = itemsByID[itemID] else { continue }
            guard selectedIDs.insert(itemID).inserted else { continue }
            selected.append(item)
        }

        var pools = priorityPools(
            from: items,
            idFor: idFor,
            priorityFor: priorityFor,
            excludingIDs: selectedIDs.union(reviewIDSet)
        )

        // 2. Fill the rest with unseen and learning only.
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

    private static func priorityPools<Item, ID>(
        from items: [Item],
        idFor: (Item) -> ID,
        priorityFor: (ID) -> QuestionSelectionPriority,
        excludingIDs: Set<ID>
    ) -> [QuestionSelectionPriority: [Item]] where ID: Hashable {
        var pools = Dictionary(
            uniqueKeysWithValues: QuestionSelectionPriority.allCases.map { ($0, [Item]()) }
        )
        pools.reserveCapacity(QuestionSelectionPriority.allCases.count)

        for item in items where !excludingIDs.contains(idFor(item)) {
            pools[priorityFor(idFor(item)), default: []].append(item)
        }

        for priority in QuestionSelectionPriority.allCases {
            pools[priority]?.shuffle()
        }

        return pools
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
