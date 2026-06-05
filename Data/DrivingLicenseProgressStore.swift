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

    func completedCount() -> Int {
        completedStepIDs.count
    }

    func toggle(_ step: DrivingLicenseStep) {
        if completedStepIDs.contains(step.id) {
            completedStepIDs.remove(step.id)
        } else {
            completedStepIDs.insert(step.id)
        }
        save()
    }

    func setCompleted(_ step: DrivingLicenseStep, completed: Bool) {
        if completed {
            completedStepIDs.insert(step.id)
        } else {
            completedStepIDs.remove(step.id)
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
