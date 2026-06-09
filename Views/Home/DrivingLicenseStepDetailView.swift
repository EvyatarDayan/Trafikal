//
//  DrivingLicenseStepDetailView.swift
//  Trafikal
//

import SwiftUI

struct DrivingLicenseStepDetailView: View {
    @Environment(LocalizationManager.self) private var l10n

    let step: DrivingLicenseStep

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
                        .foregroundStyle(Theme.appBlue)
                        .fixedSize(horizontal: false, vertical: true)

                    detailText
                        .font(.body)
                        .foregroundStyle(.primary)
                        .tint(Color.accentColor)
                        .fixedSize(horizontal: false, vertical: true)
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
