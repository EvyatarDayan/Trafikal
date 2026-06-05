//
//  GoalTabView.swift
//  Trafikal
//

import SwiftUI

struct GoalTabView: View {
    @Environment(LocalizationManager.self) private var l10n

    private let horizontalPadding: CGFloat = 24
    private let heroGray = Color(.darkGray)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 4) {
                        Text(l10n.text(.tabGoal))
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(heroGray)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(l10n.text(.homeLicenseStepsTitle))
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 28)

                    DrivingLicenseStepsSection(showsTitle: false)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 24)
            }
        }
        .appRootScreen()
        .appScreenBackground()
    }
}

#Preview {
    NavigationStack {
        GoalTabView()
    }
    .environment(LocalizationManager.shared)
    .environment(DrivingLicenseProgressStore.shared)
}
