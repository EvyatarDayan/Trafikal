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
    @State private var navigationDirection: BrowseNavigationDirection = .forward

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
            ZStack {
                ScreenTitleBar(
                    title: l10n.text(.studyTitle),
                    subtitle: l10n.text(.studyOf, index + 1, signs.count),
                    showsBackButton: true
                )

                HStack {
                    Spacer()
                    SignFavoriteButton(signCode: sign.code)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            ZStack {
                studyPage
                    .transition(.browseSlide(navigationDirection))
            }
            .clipped()
            .frame(maxHeight: .infinity)
            .animation(.browsePage, value: index)

            navigationSection
                .browseNavigationSlot()
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
        .swipeNavigation(
            onPrevious: previous,
            onNext: next,
            canGoPrevious: index > 0,
            canGoNext: index < signs.count - 1
        )
    }

    private var studyPage: some View {
        VStack(spacing: 0) {
            SignSummaryCard(sign: sign, maxImageSide: signImageMaxSide)
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, ListCardStyle.rowSpacing)

            SignMeaningScrollPanel(sign: sign, background: meaningPanelBackground)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.bottom, 8)
        }
        .id(index)
    }

    private var navigationSection: some View {
        BrowseNavigationBar(
            previousTitle: l10n.text(.studyPrevious),
            nextTitle: l10n.text(.studyNext),
            canGoPrevious: index > 0,
            canGoNext: index < signs.count - 1,
            onPrevious: previous,
            onNext: next
        )
    }

    private func next() {
        guard index < signs.count - 1 else { return }
        navigationDirection = .forward
        withAnimation(.browsePage) {
            index += 1
        }
    }

    private func previous() {
        guard index > 0 else { return }
        navigationDirection = .backward
        withAnimation(.browsePage) {
            index -= 1
        }
    }
}
