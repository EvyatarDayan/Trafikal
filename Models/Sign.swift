//
//  Sign.swift
//  Trafikal
//

import Foundation

struct Sign: Identifiable, Codable, Hashable, Sendable {
    let code: String
    let category: SignCategory
    let name: String
    let meaning: String
    let keywords: [String]
    let imageName: String?
    let numericValue: Int?
    let valueUnit: String?
    let relatedCodes: [String]
    let difficulty: Int
    let examTip: String?

    var id: String { code }

    var displayValue: String? {
        guard let numericValue else { return nil }
        if let valueUnit, !valueUnit.isEmpty {
            return "\(numericValue) \(valueUnit)"
        }
        return "\(numericValue)"
    }
}

struct SignsBundle: Codable, Sendable {
    let signs: [Sign]
}
