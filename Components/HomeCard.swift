//
//  HomeCard.swift
//  Trafikal
//

import SwiftUI

struct HomeCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    var elevated: Bool = false
    var cornerRadius: CGFloat = 12
    @ViewBuilder let content: Content

    private var cardBackground: Color {
        colorScheme == .light ? Color(.systemBackground) : Color(.secondarySystemBackground)
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: .black.opacity(elevated ? (colorScheme == .light ? 0.1 : 0.28) : 0.05),
                radius: elevated ? 12 : 4,
                x: 0,
                y: elevated ? 5 : 1
            )
    }
}
