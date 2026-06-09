//
//  TheoryQuestionDetailSheet.swift
//  Trafikal
//

import SwiftUI

/// Bottom sheet with full question explanation — matches the sign test detail sheet pattern.
struct TheoryQuestionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var l10n

    let question: TheoryQuestion

    var body: some View {
        VStack(spacing: 16) {
            explanationPanel
                .frame(maxHeight: .infinity)

            Button(l10n.text(.historyGotIt)) {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var explanationPanel: some View {
        let background = Color(.systemGray6)
        let fadeHeight: CGFloat = 40

        return VStack(alignment: .leading, spacing: 0) {
            Text(l10n.text(.questionsExplanation))
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.appBlue)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

            ZStack {
                ScrollView {
                    Text(question.explanation)
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .padding(.vertical, fadeHeight * 0.65)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollContentBackground(.hidden)
                .id(question.id)

                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [background, background.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: fadeHeight)

                    Spacer(minLength: 0)

                    LinearGradient(
                        colors: [background.opacity(0), background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: fadeHeight)
                }
                .allowsHitTesting(false)
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
