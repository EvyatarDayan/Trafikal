//
//  Theme.swift
//  Trafikal
//

import SwiftUI

enum Theme {
    /// Light gray background used across the app (Settings-style grouped gray).
    static let screenBackground = Color(.systemGroupedBackground)

    /// Test and review-mistakes screens: pure black in dark mode so cards read clearly.
    static func quizScreenBackground(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black : screenBackground
    }

    /// Primary app blue (#175e9b).
    static let appBlue = Color(red: 23 / 255, green: 94 / 255, blue: 155 / 255)

    /// Welcome screen background - light gray in light mode, grouped dark in dark mode.
    static var welcomeBackground: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? .systemGroupedBackground
                : UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)
        })
    }
}

extension View {
    /// Full-screen light gray behind content, including safe areas.
    func appScreenBackground() -> some View {
        background {
            Theme.screenBackground
                .ignoresSafeArea()
        }
    }

    /// Hides default List/Form scroll background so grouped gray shows through.
    func appListSurface() -> some View {
        scrollContentBackground(.hidden)
            .background(Theme.screenBackground)
    }

    /// Tab roots: no empty navigation bar above the title.
    func appRootScreen() -> some View {
        toolbar(.hidden, for: .navigationBar)
    }

    /// Pushed screens: compact bar with back button, same gray background.
    func appPushedScreen() -> some View {
        navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbarBackground(Theme.screenBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
