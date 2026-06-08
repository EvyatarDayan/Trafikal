//
//  ExamReadinessIndicator.swift
//  Trafikal
//

import SwiftUI

enum ExamReadinessLevel: CaseIterable {
    case notReady
    case gettingClose
    case ready

    /// Matches the 80% pass mark for the Swedish theory test.
    static func from(percent: Int) -> ExamReadinessLevel {
        let clamped = min(max(percent, 0), 100)
        switch clamped {
        case 80...:
            return .ready
        case 70..<80:
            return .gettingClose
        default:
            return .notReady
        }
    }

    var accentColor: Color {
        switch self {
        case .notReady:
            return .red
        case .gettingClose:
            return .orange
        case .ready:
            return .green
        }
    }

    func titleKey(hasTests: Bool) -> StringKey {
        guard hasTests else { return .homeExamReadinessNoTests }
        switch self {
        case .notReady:
            return .homeExamReadinessNotReady
        case .gettingClose:
            return .homeExamReadinessGettingClose
        case .ready:
            return .homeExamReadinessReady
        }
    }

    var emoji: String {
        switch self {
        case .notReady:
            return "🔴"
        case .gettingClose:
            return "🟡"
        case .ready:
            return "🟢"
        }
    }
}

struct ExamReadinessIndicator: View {
    @Environment(LocalizationManager.self) private var l10n

    let percent: Int
    let level: ExamReadinessLevel
    let hasTests: Bool

    private let barHeight: CGFloat = 28

    private var fillProgress: CGFloat {
        CGFloat(min(max(percent, 0), 100)) / 100
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("\(hasTests ? percent : 0)%")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(level.accentColor)
                .contentTransition(.numericText())

            progressBar

            if hasTests {
                Text(l10n.text(.homeExamReadinessBasedOn))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text(l10n.text(.homeExamReadinessNoTests))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            statusTrack
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let fillWidth = max(width * fillProgress, hasTests && fillProgress > 0 ? barHeight : 0)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                level.accentColor.opacity(0.85),
                                level.accentColor
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

    private var statusTrack: some View {
        HStack(spacing: 4) {
            ForEach(Array(ExamReadinessLevel.allCases.enumerated()), id: \.offset) { index, step in
                if index > 0 {
                    Text("➔")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                statusChip(for: step)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func statusChip(for step: ExamReadinessLevel) -> some View {
        let isActive = hasTests && step == level

        return Text("\(step.emoji) \(l10n.text(step.titleKey(hasTests: true)))")
            .font(.caption.weight(isActive ? .bold : .regular))
            .foregroundStyle(isActive ? step.accentColor : .secondary)
            .opacity(isActive ? 1 : 0.55)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }
}
