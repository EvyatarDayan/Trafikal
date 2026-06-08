//
//  DrivingLicenseProgressStore.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class DrivingLicenseProgressStore {
    static let shared = DrivingLicenseProgressStore()

    private(set) var completedStepIDs: Set<String> = []

    private let storageKey = "trafikal.drivingLicenseCompletedSteps"

    private init() {
        load()
    }

    func isCompleted(_ step: DrivingLicenseStep) -> Bool {
        completedStepIDs.contains(step.id)
    }

    func canMarkComplete(_ step: DrivingLicenseStep) -> Bool {
        guard !isCompleted(step) else { return false }
        return step.previousSteps.allSatisfy { isCompleted($0) }
    }

    func completedCount() -> Int {
        completedStepIDs.count
    }

    var areAllStepsCompleted: Bool {
        DrivingLicenseStep.allCases.allSatisfy { isCompleted($0) }
    }

    func toggle(_ step: DrivingLicenseStep) {
        if isCompleted(step) {
            unmarkFrom(step)
        } else if canMarkComplete(step) {
            completedStepIDs.insert(step.id)
            save()
        }
    }

    func setCompleted(_ step: DrivingLicenseStep, completed: Bool) {
        if completed {
            guard canMarkComplete(step) else { return }
            completedStepIDs.insert(step.id)
        } else {
            unmarkFrom(step)
        }
        save()
    }

    private func unmarkFrom(_ step: DrivingLicenseStep) {
        guard let index = DrivingLicenseStep.allCases.firstIndex(of: step) else { return }
        for following in DrivingLicenseStep.allCases.suffix(from: index) {
            completedStepIDs.remove(following.id)
        }
        save()
    }

    private func load() {
        guard let saved = UserDefaults.standard.array(forKey: storageKey) as? [String] else { return }
        completedStepIDs = Set(saved)
    }

    private func save() {
        UserDefaults.standard.set(Array(completedStepIDs), forKey: storageKey)
    }
}
