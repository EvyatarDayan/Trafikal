//
//  MaterialCoverageRow.swift
//  Trafikal
//

import SwiftUI

struct MaterialCoverageRow: View {
    @Environment(LocalizationManager.self) private var l10n

    let title: String
    let coverage: MaterialCoverage

    private let barHeight: CGFloat = 10

    private var fillProgress: CGFloat {
        CGFloat(min(max(coverage.percent, 0), 100)) / 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Spacer(minLength: 12)

                Text(l10n.text(.homeMaterialCoverageCount, coverage.seen, coverage.total))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()

                Text("\(coverage.percent)%")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.appBlue)
                    .monospacedDigit()
                    .frame(minWidth: 40, alignment: .trailing)
            }

            progressBar
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let fillWidth = max(width * fillProgress, coverage.hasStarted && fillProgress > 0 ? barHeight : 0)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.appBlue.opacity(0.85),
                                Theme.appBlue
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth)
            }
        }
        .frame(height: barHeight)
    }
}
