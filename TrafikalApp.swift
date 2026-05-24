//
//  TrafikalApp.swift
//  Trafikal
//

import SwiftUI
import UIKit

@main
struct TrafikalApp: App {
    private let catalog = SignCatalog.shared
    private let theoryCatalog = TheoryQuestionCatalog.shared
    private let testHistory = TestHistoryStore.shared
    private let localization = LocalizationManager.shared

    init() {
        let background = UIColor.systemGroupedBackground

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = background
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(catalog)
                .environment(theoryCatalog)
                .environment(testHistory)
                .environment(localization)
                .environment(TestSessionStore.shared)
                .environment(TheoryQuestionSessionStore.shared)
        }
    }
}
