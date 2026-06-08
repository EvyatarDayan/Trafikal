//
//  DrivingLicenseStep.swift
//  Trafikal
//

import Foundation

enum DrivingLicenseStep: String, CaseIterable, Identifiable {
    case permit
    case eyeCheck
    case risk1
    case risk2
    case theoryTest
    case drivingLessons
    case drivingTest
    case pickUpLicense

    var id: String { rawValue }

    var number: Int {
        switch self {
        case .permit: 1
        case .eyeCheck: 2
        case .risk1: 3
        case .risk2: 4
        case .theoryTest: 5
        case .drivingLessons: 6
        case .drivingTest: 7
        case .pickUpLicense: 8
        }
    }

    var titleKey: StringKey {
        switch self {
        case .permit: .licensePermitTitle
        case .eyeCheck: .licenseEyeCheckTitle
        case .risk1: .licenseRisk1Title
        case .risk2: .licenseRisk2Title
        case .theoryTest: .licenseTheoryTestTitle
        case .drivingLessons: .licenseDrivingLessonsTitle
        case .drivingTest: .licenseDrivingTestTitle
        case .pickUpLicense: .licensePickUpTitle
        }
    }

    var detailKey: StringKey {
        switch self {
        case .permit: .licensePermitDetail
        case .eyeCheck: .licenseEyeCheckDetail
        case .risk1: .licenseRisk1Detail
        case .risk2: .licenseRisk2Detail
        case .theoryTest: .licenseTheoryTestDetail
        case .drivingLessons: .licenseDrivingLessonsDetail
        case .drivingTest: .licenseDrivingTestDetail
        case .pickUpLicense: .licensePickUpDetail
        }
    }

    var previousSteps: [DrivingLicenseStep] {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self) else { return [] }
        return Array(all.prefix(index))
    }
}
