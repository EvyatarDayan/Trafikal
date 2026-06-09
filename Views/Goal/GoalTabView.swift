//
//  GoalTabView.swift
//  Trafikal
//

import SwiftUI

struct GoalTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(DrivingLicenseProgressStore.self) private var progressStore
    @Environment(\.colorScheme) private var colorScheme

    private let horizontalPadding: CGFloat = 24
    private let licenseImageMaxWidth: CGFloat = 240
    private let bottomFadeHeight: CGFloat = 50

    private var isLicenseStepCompleted: Bool {
        progressStore.isCompleted(.pickUpLicense)
    }

    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 4) {
                        Text(l10n.text(.tabGoal))
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Theme.appBlue)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(l10n.text(.goalSubtitle))
                            .font(.title3.bold())
                            .foregroundStyle(Theme.appBlue)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 28)

                    DrivingLicenseStepsSection(showsTitle: false)

                    licenseSection
                        .padding(.top, 12)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, bottomFadeHeight + 16)
                .drivingLicenseTimelineBackground(colorScheme: colorScheme) { step in
                    progressStore.isCompleted(step)
                }
            }
            .overlay(alignment: .bottom) {
                bottomScrollFade
            }
        }
        .confettiCelebration(isVisible: $showConfetti)
        .onChange(of: progressStore.areAllStepsCompleted) { wasComplete, isComplete in
            if isComplete, !wasComplete {
                replayConfetti()
            }
        }
        .appRootScreen()
        .appScreenBackground()
    }

    private var bottomScrollFade: some View {
        LinearGradient(
            colors: [
                Theme.screenBackground.opacity(0),
                Theme.screenBackground.opacity(0.85),
                Theme.screenBackground
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: bottomFadeHeight)
        .allowsHitTesting(false)
    }

    private var licenseSection: some View {
        VStack(spacing: 10) {
            licenseImage

            if progressStore.areAllStepsCompleted {
                Text(l10n.text(.licenseAllStepsCompleted))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.green)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var licenseImage: some View {
        licenseImageContent
            .frame(maxWidth: .infinity)
    }

    private var licenseImageContent: some View {
        Image("License")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: licenseImageMaxWidth)
            .clipShape(RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
            .compositingGroup()
            .overlay {
                if isLicenseStepCompleted {
                    RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                        .strokeBorder(Color.green.opacity(0.55), lineWidth: 2.5)
                }
            }
            .trafikalDropShadow(colorScheme: colorScheme)
            .confettiBurstAnchor()
            .drivingLicenseTimelineTerminalAnchor()
            .contentShape(RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
            .onTapGesture {
                guard isLicenseStepCompleted else { return }
                replayConfetti()
            }
            .accessibilityAddTraits(isLicenseStepCompleted ? .isButton : [])
    }

    private func replayConfetti() {
        if showConfetti {
            showConfetti = false
            DispatchQueue.main.async {
                showConfetti = true
            }
        } else {
            showConfetti = true
        }
    }
}

#Preview {
    NavigationStack {
        GoalTabView()
    }
    .environment(LocalizationManager.shared)
    .environment(DrivingLicenseProgressStore.shared)
}
