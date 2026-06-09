//
//  SimulationSessionProgressHeader.swift
//  Trafikal
//

import SwiftUI

struct SimulationSessionProgressHeader: View {
    let currentIndex: Int
    let totalCount: Int
    let remainingSeconds: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Spacer()
                Text(formattedTime)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(remainingSeconds <= 300 ? Color.red : Theme.appBlue)
            }
            .padding(.horizontal)

            ProgressView(
                value: Double(currentIndex + 1),
                total: Double(totalCount)
            )

            Text("\(currentIndex + 1)/\(totalCount)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Theme.screenBackground)
    }

    private var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
