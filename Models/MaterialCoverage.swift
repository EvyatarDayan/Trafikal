//
//  MaterialCoverage.swift
//  Trafikal
//

import Foundation

struct MaterialCoverage: Sendable, Equatable {
    let seen: Int
    let total: Int

    var percent: Int {
        guard total > 0 else { return 0 }
        return min(seen * 100 / total, 100)
    }

    var hasStarted: Bool {
        seen > 0
    }
}
