//
//  SignMeaningScrollPanel.swift
//  Trafikal
//

import SwiftUI

/// Scrollable meaning panel with edge fades - shared by sign study and test detail sheets.
struct SignMeaningScrollPanel: View {
    @Environment(LocalizationManager.self) private var l10n

    let sign: Sign
    /// When true, shows the full sign name at the top of the scroll area (e.g. test detail sheet).
    var showsSignName: Bool = false
    var background: Color = Color(.systemGray6)
    private let fadeHeight: CGFloat = 40

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(l10n.text(.studyMeaning))
                .font(.headline.weight(.semibold))
                .foregroundStyle(Theme.appBlue)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if showsSignName {
                            Text(sign.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Text(sign.meaning)
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let tip = sign.examTip, !tip.isEmpty {
                            Label(tip, systemImage: "lightbulb.fill")
                                .font(.body)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, fadeHeight * 0.65)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollContentBackground(.hidden)
                .id(sign.id)

                VStack(spacing: 0) {
                    meaningEdgeFade(edge: .top)
                    Spacer(minLength: 0)
                    meaningEdgeFade(edge: .bottom)
                }
                .allowsHitTesting(false)
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private enum MeaningFadeEdge {
        case top, bottom
    }

    private func meaningEdgeFade(edge: MeaningFadeEdge) -> some View {
        LinearGradient(
            colors: edge == .top
                ? [background, background.opacity(0)]
                : [background.opacity(0), background],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: fadeHeight)
    }
}
