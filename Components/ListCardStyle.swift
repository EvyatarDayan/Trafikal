//
//  ListCardStyle.swift
//  Trafikal
//

import SwiftUI

enum ListCardStyle {
    static let cornerRadius: CGFloat = 12
    static let horizontalPadding: CGFloat = 16
    static let rowSpacing: CGFloat = 12
    static let rowVerticalPadding: CGFloat = 14
    static let rowHorizontalPadding: CGFloat = 14

    static func cardBackground(colorScheme: ColorScheme) -> Color {
        colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6)
    }
}

extension View {
    func listCardStyle(
        background: Color,
        cornerRadius: CGFloat = ListCardStyle.cornerRadius,
        horizontalPadding: CGFloat = ListCardStyle.rowHorizontalPadding,
        verticalPadding: CGFloat = ListCardStyle.rowVerticalPadding,
        colorScheme: ColorScheme
    ) -> some View {
        padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(colorScheme == .light ? 0.06 : 0), radius: 4, x: 0, y: 2)
    }
}
