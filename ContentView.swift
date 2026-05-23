//
//  ContentView.swift
//  Trafikal
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedTab = 2

    private let menuHeight: CGFloat = 40
    private let menuButtonSpacing: CGFloat = -40

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.screenBackground
                    .ignoresSafeArea()

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
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            NavigationStack { StudyTabRoot() }
        case 1:
            NavigationStack { CategoryListView() }
        case 2:
            NavigationStack { HomeTabView() }
        case 3:
            NavigationStack { TestsTabView() }
        case 4:
            NavigationStack { QuestionsTabView() }
        case 5:
            NavigationStack { SettingsView() }
        default:
            NavigationStack { HomeTabView() }
        }
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
                    icon: "book.fill",
                    label: "Study",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )

                TabBarButton(
                    icon: "square.grid.2x2.fill",
                    label: "Categories",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )

                TabBarButton(
                    icon: "house.fill",
                    label: "Home",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )

                TabBarButton(
                    icon: "list.clipboard.fill",
                    label: "Tests",
                    isSelected: selectedTab == 3,
                    action: { selectedTab = 3 }
                )

                TabBarButton(
                    icon: "text.book.closed.fill",
                    label: "Questions",
                    isSelected: selectedTab == 4,
                    action: { selectedTab = 4 }
                )

                TabBarButton(
                    icon: "gearshape.fill",
                    label: "Settings",
                    isSelected: selectedTab == 5,
                    action: { selectedTab = 5 }
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
}
