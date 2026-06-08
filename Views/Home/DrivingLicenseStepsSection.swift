//
//  DrivingLicenseStepsSection.swift
//  Trafikal
//

import SwiftUI

struct DrivingLicenseStepsSection: View {
    var showsTitle: Bool = true

    @Environment(LocalizationManager.self) private var l10n
    @Environment(DrivingLicenseProgressStore.self) private var progressStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 14) {
            if showsTitle {
                Text(l10n.text(.homeLicenseStepsTitle))
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
            }

            VStack(spacing: ListCardStyle.rowSpacing) {
                ForEach(DrivingLicenseStep.allCases) { step in
                    DrivingLicenseStepRow(step: step)
                }
            }
        }
    }
}

private struct DrivingLicenseStepRow: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(DrivingLicenseProgressStore.self) private var progressStore
    @Environment(\.colorScheme) private var colorScheme

    let step: DrivingLicenseStep

    private var isCompleted: Bool {
        progressStore.isCompleted(step)
    }

    private var canMarkComplete: Bool {
        progressStore.canMarkComplete(step)
    }

    private var isLocked: Bool {
        !isCompleted && !canMarkComplete
    }

    private var isCurrent: Bool {
        canMarkComplete
    }

    private var currentOutlineColor: Color {
        colorScheme == .light ? .black : Color.white.opacity(0.9)
    }

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        HStack(spacing: 10) {
            completionCheckbox

            NavigationLink {
                DrivingLicenseStepDetailView(step: step)
            } label: {
                HStack(spacing: 12) {
                    stepIndicator

                    HStack(spacing: 8) {
                        Text(l10n.text(step.titleKey))
                            .font(.body.weight(isCurrent ? .bold : .regular))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .listCardStyle(
            background: isCompleted ? Color.green.opacity(colorScheme == .light ? 0.12 : 0.18) : cardBackground,
            horizontalPadding: 12,
            verticalPadding: 12,
            colorScheme: colorScheme
        )
        .contentShape(RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
        .overlay {
            if isCompleted {
                RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(Color.green.opacity(0.45), lineWidth: 1.5)
            } else if isCurrent {
                RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(currentOutlineColor, lineWidth: 1)
            }
        }
        .opacity(isLocked ? 0.72 : 1)
        .modifier(LastStepRowCenterAnchorModifier(stepNumber: step.number))
    }

    private var completionCheckbox: some View {
        Button {
            progressStore.toggle(step)
        } label: {
            Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                .font(.title3)
                .foregroundStyle(checkboxColor)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
        .accessibilityLabel(rowAccessibilityLabel)
    }

    private var checkboxColor: Color {
        if isLocked {
            return .secondary.opacity(0.45)
        }
        if isCompleted {
            return .green
        }
        return .secondary
    }

    private var rowAccessibilityLabel: String {
        if isCompleted {
            l10n.text(.licenseMarkNotDone)
        } else if canMarkComplete {
            l10n.text(.licenseMarkDone)
        } else {
            l10n.text(.licensePreviousItemsNotDone)
        }
    }

    @ViewBuilder
    private var stepIndicator: some View {
        Text("\(step.number)")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isCompleted ? .white : .secondary)
            .frame(width: 26, height: 26)
            .background(isCompleted ? Color.green : Color(.systemGray5), in: Circle())
            .drivingLicenseStepCircleAnchor(stepNumber: step.number)
    }
}

private struct LastStepRowCenterAnchorModifier: ViewModifier {
    let stepNumber: Int

    func body(content: Content) -> some View {
        if stepNumber == DrivingLicenseStep.pickUpLicense.number {
            content.drivingLicenseLastStepRowCenterAnchor()
        } else {
            content
        }
    }
}
