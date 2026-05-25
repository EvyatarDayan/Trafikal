//
//  StudyCardView.swift
//  Trafikal
//

import SwiftUI

struct StudyCardView: View {
    @Environment(LocalizationManager.self) private var l10n

    private let signImageMaxSide: CGFloat = 200
    private let meaningFadeHeight: CGFloat = 40

    let signs: [Sign]
    let startIndex: Int

    @State private var index: Int

    init(signs: [Sign], startIndex: Int = 0) {
        self.signs = signs
        self.startIndex = startIndex
        _index = State(initialValue: startIndex)
    }

    private var sign: Sign {
        signs[index]
    }

    private var meaningPanelBackground: Color {
        Color(.systemGray6)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: l10n.text(.studyTitle),
                subtitle: l10n.text(.studyOf, index + 1, signs.count),
                showsBackButton: true
            )

            signCard
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, ListCardStyle.rowSpacing)

            meaningPanel
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.bottom, 8)

            navigationSection
                .frame(height: 72)
                .background(Theme.screenBackground)
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
        .id(sign.id)
    }

    private var signCard: some View {
        SignSummaryCard(sign: sign, maxImageSide: signImageMaxSide)
    }

    private var meaningPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(l10n.text(.studyMeaning))
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
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
                    .padding(.vertical, meaningFadeHeight * 0.65)
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
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(meaningPanelBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private enum MeaningFadeEdge {
        case top, bottom
    }

    private func meaningEdgeFade(edge: MeaningFadeEdge) -> some View {
        LinearGradient(
            colors: edge == .top
                ? [meaningPanelBackground, meaningPanelBackground.opacity(0)]
                : [meaningPanelBackground.opacity(0), meaningPanelBackground],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: meaningFadeHeight)
    }

    private var navigationSection: some View {
        HStack(spacing: 16) {
            Button(l10n.text(.studyPrevious)) {
                previous()
            }
            .buttonStyle(.borderedProminent)
            .disabled(index == 0)
            .frame(maxWidth: .infinity)

            Button(l10n.text(.studyNext)) {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(index >= signs.count - 1)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
    }

    private func next() {
        guard index < signs.count - 1 else { return }
        index += 1
    }

    private func previous() {
        guard index > 0 else { return }
        index -= 1
    }
}
