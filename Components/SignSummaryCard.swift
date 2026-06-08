//
//  SignSummaryCard.swift
//  Trafikal
//

import SwiftUI

/// Sign image, code, and name - matches the white card on the signs detail screen.
struct SignSummaryCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(LocalizationManager.self) private var l10n

    let sign: Sign
    var maxImageSide: CGFloat = 200
    var nameLineLimit: Int?
    var imageShadow: Bool = false
    /// When set, shown instead of the sign name (e.g. test quiz prompt).
    var promptText: String?
    var showsSignName: Bool = true
    var showsInfoButton: Bool = false
    var onInfoTap: (() -> Void)?

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 12) {
            if let promptText {
                Text(promptText)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            signImage

            Text(sign.code)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.systemGray5), in: Capsule())

            if showsSignName, promptText == nil {
                signName
            }
        }
        .frame(maxWidth: .infinity)
        .listCardStyle(background: cardBackground, colorScheme: colorScheme)
        .overlay(alignment: .topTrailing) {
            if showsInfoButton, let onInfoTap {
                infoButton(action: onInfoTap)
                    .padding(.top, 10)
                    .padding(.trailing, 10)
            }
        }
    }

    @ViewBuilder
    private var signName: some View {
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


    @ViewBuilder
    private var signImage: some View {
        let image = SignImageView(sign: sign, maxSide: maxImageSide)

        Group {
            if imageShadow {
                image.trafikalDropShadow(colorScheme: colorScheme)
            } else {
                image
            }
        }
    }

    private func infoButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(l10n.text(.homeDetails))
    }
}
