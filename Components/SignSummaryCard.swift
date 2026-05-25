//
//  SignSummaryCard.swift
//  Trafikal
//

import SwiftUI

/// Sign image, code, and name — matches the white card on the signs detail screen.
struct SignSummaryCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let sign: Sign
    var maxImageSide: CGFloat = 200
    var nameLineLimit: Int?
    var imageShadow: Bool = false

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 12) {
            signImage

            Text(sign.code)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.systemGray5), in: Capsule())

            Group {
                if let nameLineLimit {
                    Text(sign.name)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(nameLineLimit)
                        .truncationMode(.tail)
                } else {
                    Text(sign.name)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
    }

    @ViewBuilder
    private var signImage: some View {
        let image = SignImageView(sign: sign, maxSide: maxImageSide)

        if imageShadow {
            image.trafikalDropShadow(colorScheme: colorScheme)
        } else {
            image
        }
    }
}
