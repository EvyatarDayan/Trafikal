//
//  StudyCardView.swift
//  Trafikal
//

import SwiftUI

struct StudyCardView: View {
    private let horizontalInset: CGFloat = 20
    private let meaningTextInset: CGFloat = 36
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

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: "Study",
                subtitle: "\(index + 1) of \(signs.count)",
                showsBackButton: true
            )

            GeometryReader { geometry in
                let topHeight = geometry.size.height * 0.4
                let middleHeight = geometry.size.height * 0.4
                let bottomHeight = geometry.size.height * 0.2
                let signImageSide = min(geometry.size.width * 0.55, topHeight * 0.55)

                VStack(spacing: 0) {
                    signSection(imageSide: signImageSide)
                        .frame(width: geometry.size.width, height: topHeight)

                    sectionDivider

                    meaningSection(height: middleHeight)
                        .frame(width: geometry.size.width, height: middleHeight)

                    sectionDivider

                    navigationSection
                        .frame(width: geometry.size.width, height: bottomHeight)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.black.opacity(0.35))
            .frame(height: 3)
            .padding(.horizontal, horizontalInset)
    }

    private func signSection(imageSide: CGFloat) -> some View {
        VStack(spacing: 12) {
            SignImageView(sign: sign, maxSide: imageSide)

            VStack(spacing: 6) {
                Text(sign.code)
                    .font(.caption.bold())
                    .foregroundStyle(sign.category.accentColor)

                Text(sign.name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func meaningSection(height: CGFloat) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(sign.meaning)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, meaningTextInset)

                    if let tip = sign.examTip, !tip.isEmpty {
                        Label(tip, systemImage: "lightbulb.fill")
                            .font(.callout)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, horizontalInset)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: height, alignment: .center)
                .padding(.vertical, meaningFadeHeight * 0.65)
            }

            VStack(spacing: 0) {
                meaningEdgeFade(edge: .top)
                Spacer(minLength: 0)
                meaningEdgeFade(edge: .bottom)
            }
            .allowsHitTesting(false)
        }
        .frame(height: height)
        .background(Theme.screenBackground)
        .id(sign.id)
    }

    private enum MeaningFadeEdge {
        case top, bottom
    }

    private func meaningEdgeFade(edge: MeaningFadeEdge) -> some View {
        LinearGradient(
            colors: edge == .top
                ? [Theme.screenBackground, Theme.screenBackground.opacity(0)]
                : [Theme.screenBackground.opacity(0), Theme.screenBackground],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: meaningFadeHeight)
    }

    private var navigationSection: some View {
        HStack(spacing: 16) {
            Button("Previous") {
                previous()
            }
            .buttonStyle(.borderedProminent)
            .disabled(index == 0)
            .frame(maxWidth: .infinity)

            Button("Next") {
                next()
            }
            .buttonStyle(.borderedProminent)
            .disabled(index >= signs.count - 1)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

