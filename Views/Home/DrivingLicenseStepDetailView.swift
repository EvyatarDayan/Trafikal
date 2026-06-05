//
//  DrivingLicenseStepDetailView.swift
//  Trafikal
//

import SwiftUI

struct DrivingLicenseStepDetailView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(DrivingLicenseProgressStore.self) private var progressStore
    @Environment(\.colorScheme) private var colorScheme

    let step: DrivingLicenseStep

    private let detailImageMaxWidth: CGFloat = 280

    private var isCompleted: Bool {
        progressStore.isCompleted(step)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: l10n.text(.homeLicenseStepsTitle),
                subtitle: l10n.text(.licenseStepNumber, step.number),
                showsBackButton: true
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(l10n.text(step.titleKey))
                        .font(.title2.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)

                    detailText
                        .font(.body)
                        .foregroundStyle(.primary)
                        .tint(Color.accentColor)
                        .fixedSize(horizontal: false, vertical: true)

                    if let imageName = step.detailImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
                            .compositingGroup()
                            .frame(maxWidth: detailImageMaxWidth)
                            .frame(maxWidth: .infinity)
                            .trafikalDropShadow(colorScheme: colorScheme)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                    }

                    Button {
                        progressStore.toggle(step)
                    } label: {
                        Label(
                            l10n.text(isCompleted ? .licenseMarkNotDone : .licenseMarkDone),
                            systemImage: isCompleted ? "circle" : "checkmark.circle.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isCompleted ? Color(.systemGray3) : .green)
                    .controlSize(.large)
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .appScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var detailText: Text {
        let markdown = l10n.text(step.detailKey)

        if let attributed = try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(attributed)
        }

        return Text(markdown)
    }
}
