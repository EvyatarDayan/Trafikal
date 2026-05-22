//
//  StudyCardView.swift
//  Trafikal
//

import SwiftUI

struct StudyCardView: View {
    private let horizontalInset: CGFloat = 20
    private let meaningTextInset: CGFloat = 36

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

                    meaningSection
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

    private var meaningSection: some View {
        ScrollView {
            meaningContent
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
        }
        .id(sign.id)
    }

    private var meaningContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sign.meaning)
                .font(.body)
                .foregroundStyle(.primary)
                .padding(.horizontal, meaningTextInset)
                .padding(.top, 28)

            if let tip = sign.examTip, !tip.isEmpty {
                Label(tip, systemImage: "lightbulb.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, horizontalInset)
            }

            if !sign.keywords.isEmpty {
                FlowTagsView(tags: sign.keywords)
                    .padding(.horizontal, horizontalInset)
            }
        }
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

private struct FlowTagsView: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.thinMaterial, in: Capsule())
                }
            }
        }
    }
}
