//
//  TrafikalDropShadow.swift
//  Trafikal
//

import SwiftUI

extension View {
    /// Drop shadow used on the home sign-of-the-day image and matching chart elements.
    func trafikalDropShadow(colorScheme: ColorScheme) -> some View {
        shadow(
            color: .black.opacity(colorScheme == .light ? 0.22 : 0.5),
            radius: 14,
            x: 0,
            y: 7
        )
    }
}
