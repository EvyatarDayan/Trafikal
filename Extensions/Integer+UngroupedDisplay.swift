//
//  Integer+UngroupedDisplay.swift
//  Trafikal
//

import Foundation

extension BinaryInteger {
    /// Plain digits without locale grouping separators for values with 4+ digits (e.g. 1000, not 1,000).
    var ungroupedDisplayString: String {
        let value = Int(truncatingIfNeeded: self)
        guard abs(value) > 999 else { return "\(value)" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
