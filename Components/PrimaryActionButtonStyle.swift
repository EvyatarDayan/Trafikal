//
//  PrimaryActionButtonStyle.swift
//  Trafikal
//

import SwiftUI

enum PrimaryActionButtonMetrics {
    static let defaultWidth: CGFloat = 280
}

struct PrimaryActionButtonStyle: ButtonStyle {
    var width: CGFloat = PrimaryActionButtonMetrics.defaultWidth

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: width)
            .padding(.vertical, 16)
            .background(
                Color.accentColor.opacity(configuration.isPressed ? 0.85 : 1),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    var width: CGFloat = PrimaryActionButtonMetrics.defaultWidth
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(tint)
            .frame(width: width)
            .padding(.vertical, 16)
            .background(
                tint.opacity(configuration.isPressed ? 0.18 : 0.12),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
    }
}
