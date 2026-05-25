//
//  TestResultsPieChart.swift
//  Trafikal
//

import Charts
import SwiftUI

struct TestResultsPieChart: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme

    let correct: Int
    let total: Int
    var size: CGFloat = 220
    var innerRadiusRatio: CGFloat = 0.70
    var dropShadow: Bool = false

    private var incorrect: Int { max(0, total - correct) }

    private var percentCorrect: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total) * 100).rounded())
    }

    var body: some View {
        Group {
            if dropShadow {
                chart.trafikalDropShadow(colorScheme: colorScheme)
            } else {
                chart
            }
        }
    }

    private var chart: some View {
        Chart {
            if correct > 0 {
                SectorMark(
                    angle: .value("Correct", correct),
                    innerRadius: .ratio(innerRadiusRatio),
                    angularInset: incorrect > 0 ? 2 : 0
                )
                .foregroundStyle(.green)
            }

            if incorrect > 0 {
                SectorMark(
                    angle: .value("Incorrect", incorrect),
                    innerRadius: .ratio(innerRadiusRatio),
                    angularInset: correct > 0 ? 2 : 0
                )
                .foregroundStyle(Color.red.opacity(0.85))
            }
        }
        .chartLegend(.hidden)
        .frame(width: size, height: size)
        .overlay {
            VStack(spacing: 2) {
                Text("\(percentCorrect)%")
                    .font(.title.bold())
                Text(l10n.text(.testCorrectLabel))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    TestResultsPieChart(correct: 7, total: 10)
        .padding()
}
