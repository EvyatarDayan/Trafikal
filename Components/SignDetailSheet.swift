//
//  SignDetailSheet.swift
//  Trafikal
//

import SwiftUI

/// Bottom sheet with full sign description — matches the history detail sheet pattern.
struct SignDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var l10n

    let sign: Sign

    private let imageMaxSide: CGFloat = 72

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                SignImageView(sign: sign, maxSide: imageMaxSide)

                Text(sign.code)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5), in: Capsule())
            }
            .frame(maxWidth: .infinity)

            SignMeaningScrollPanel(sign: sign, showsSignName: true)
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
}
