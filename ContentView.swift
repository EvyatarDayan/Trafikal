//
//  ContentView.swift
//  Trafikal
//

import SwiftUI

struct ContentView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(AppTabRouter.self) private var tabRouter
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var hasCompletedWelcome = false

    private let menuHeight: CGFloat = 40
    private let menuButtonSpacing: CGFloat = -48

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.screenBackground
                    .ignoresSafeArea()

                if hasCompletedWelcome {
                    VStack(spacing: 0) {
                        tabContent
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height - menuHeight
                            )
                            .clipped()

                        customTabBar(width: geometry.size.width, bottomInset: geometry.safeAreaInsets.bottom)
                    }
                }

                if !hasCompletedWelcome {
                    WelcomeView(
                        titlePrefix: l10n.text(.welcomeTitlePrefix),
                        titleBrand: l10n.text(.welcomeTitleBrand),
                        subtitle: l10n.text(.welcomeSubtitle),
                        startTitle: l10n.text(.welcomeStart),
                        logoImageName: "Trafical",
                        onStart: completeWelcome
                    )
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
        .favoriteAddedConfirmationOverlay()
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func completeWelcome() {
        withAnimation(.easeOut(duration: 0.4)) {
            hasCompletedWelcome = true
        }
    }

    private var tabContent: some View {
        ZStack {
            tabRoot(HomeTabView(), tab: 0)
            tabRoot(PracticeTabView(), tab: 1)
            tabRoot(GoalTabView(), tab: 2)
            tabRoot(TestsTabView(), tab: 3)
            tabRoot(SettingsView(), tab: 4)
        }
    }

    private func tabRoot<Content: View>(_ content: Content, tab: Int) -> some View {
        NavigationStack {
            content
        }
        .opacity(tabRouter.selectedTab == tab ? 1 : 0)
        .allowsHitTesting(tabRouter.selectedTab == tab)
        .accessibilityHidden(tabRouter.selectedTab != tab)
    }

    private func customTabBar(width: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20)
                    .fill(Color(.systemBackground))
                    .frame(width: width, height: menuHeight)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: -3)

                Rectangle()
                    .fill(Color(.systemBackground))
                    .frame(width: width)
                    .frame(height: bottomInset)
            }

            HStack(spacing: menuButtonSpacing) {
                TabBarButton(
                    icon: "house.fill",
                    label: l10n.text(.tabHome),
                    isSelected: tabRouter.selectedTab == 0,
                    action: { tabRouter.selectedTab = 0 }
                )

                TabBarButton(
                    icon: "books.vertical.fill",
                    label: l10n.text(.tabPractice),
                    isSelected: tabRouter.selectedTab == 1,
                    action: { tabRouter.selectedTab = 1 }
                )

                TabBarButton(
                    icon: "flag.checkered",
                    label: l10n.text(.tabGoal),
                    isSelected: tabRouter.selectedTab == 2,
                    action: { tabRouter.selectedTab = 2 }
                )

                TabBarButton(
                    icon: "list.clipboard.fill",
                    label: l10n.text(.tabTests),
                    isSelected: tabRouter.selectedTab == 3,
                    action: { tabRouter.selectedTab = 3 }
                )

                TabBarButton(
                    icon: "gearshape.fill",
                    label: l10n.text(.tabSettings),
                    isSelected: tabRouter.selectedTab == 4,
                    action: { tabRouter.selectedTab = 4 }
                )
            }
            .frame(width: width, height: menuHeight)
        }
        .zIndex(1)
    }
}

#Preview {
    ContentView()
        .environment(SignCatalog.shared)
        .environment(TestHistoryStore.shared)
        .environment(TestSessionStore.shared)
        .environment(TheoryQuestionCatalog.shared)
        .environment(TheoryQuestionSessionStore.shared)
        .environment(TheoryQuestionProgressStore.shared)
        .environment(SignProgressStore.shared)
        .environment(SimulationSessionStore.shared)
        .environment(FavoritesStore.shared)
        .environment(DrivingLicenseProgressStore.shared)
        .environment(LocalizationManager.shared)
        .environment(AppTabRouter.shared)
}
