//
//  TestScoreRingView.swift
//  Trafikal
//

import SwiftUI

struct TestScoreRingView: View {
    let percent: Int

    private var progress: CGFloat {
        CGFloat(min(max(percent, 0), 100)) / 100
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(red: 0.92, green: 0.55, blue: 0.5).opacity(0.9), lineWidth: 14)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(red: 0.45, green: 0.78, blue: 0.55),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text("\(percent)%")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                Text("Success")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 150, height: 150)
    }
}

#Preview {
    TestScoreRingView(percent: 80)
        .padding()
}
