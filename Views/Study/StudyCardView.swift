//
//  StudyCardView.swift
//  Trafikal
//

import SwiftUI

struct StudyCardView: View {
    @Environment(LocalizationManager.self) private var l10n

    private let signImageMaxSide: CGFloat = 200

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

            SignMeaningScrollPanel(sign: sign, background: meaningPanelBackground)
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
