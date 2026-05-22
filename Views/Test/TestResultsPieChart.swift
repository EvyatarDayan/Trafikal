//
//  TestResultsPieChart.swift
//  Trafikal
//

import Charts
import SwiftUI

struct TestResultsPieChart: View {
    let correct: Int
    let total: Int

    private var incorrect: Int { max(0, total - correct) }

    private var percentCorrect: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total) * 100).rounded())
    }

    var body: some View {
        Chart {
            if correct > 0 {
                SectorMark(
                    angle: .value("Correct", correct),
                    innerRadius: .ratio(0.58),
                    angularInset: incorrect > 0 ? 2 : 0
                )
                .foregroundStyle(.green)
            }

            if incorrect > 0 {
                SectorMark(
                    angle: .value("Incorrect", incorrect),
                    innerRadius: .ratio(0.58),
                    angularInset: correct > 0 ? 2 : 0
                )
                .foregroundStyle(Color.red.opacity(0.85))
            }
        }
        .chartLegend(.hidden)
        .frame(width: 220, height: 220)
        .overlay {
            VStack(spacing: 2) {
                Text("\(percentCorrect)%")
                    .font(.title.bold())
                Text("correct")
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
