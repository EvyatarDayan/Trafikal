//
//  Theme.swift
//  Trafikal
//

import SwiftUI

enum Theme {
    /// Light gray background used across the app (Settings-style grouped gray).
    static let screenBackground = Color(.systemGroupedBackground)
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
