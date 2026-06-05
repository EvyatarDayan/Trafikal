//
//  DrivingLicenseStepsSection.swift
//  Trafikal
//

import SwiftUI

struct DrivingLicenseStepsSection: View {
    var showsTitle: Bool = true

    @Environment(LocalizationManager.self) private var l10n

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

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                progressStore.toggle(step)
            } label: {
                stepIndicator
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                l10n.text(isCompleted ? .licenseMarkNotDone : .licenseMarkDone)
            )

            NavigationLink {
                DrivingLicenseStepDetailView(step: step)
            } label: {
                HStack(spacing: 8) {
                    Text(l10n.text(step.titleKey))
                        .font(.body.weight(isCompleted ? .medium : .regular))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
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
        .overlay {
            if isCompleted {
                RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(Color.green.opacity(0.45), lineWidth: 1.5)
            }
        }
    }

    @ViewBuilder
    private var stepIndicator: some View {
        if isCompleted {
            Image(systemName: "checkmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color.green, in: Circle())
        } else {
            Text("\(step.number)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 26)
                .background(Color(.systemGray5), in: Circle())
        }
    }
}
