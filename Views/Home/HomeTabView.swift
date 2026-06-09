//
//  HomeTabView.swift
//  Trafikal
//

import SwiftUI

struct HomeTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(AppTabRouter.self) private var tabRouter
    @Environment(SignCatalog.self) private var catalog
    @Environment(TheoryQuestionCatalog.self) private var theoryCatalog
    @Environment(SignProgressStore.self) private var signProgressStore
    @Environment(TheoryQuestionProgressStore.self) private var questionProgressStore
    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(\.colorScheme) private var colorScheme

    private let horizontalPadding: CGFloat = 24
    private let cardCornerRadius: CGFloat = 16

    // TEMP: remove with `temporaryRandomSignButton` when done testing sign-of-the-day.
    @State private var signOfTodayOverride: Sign?

    private var signOfToday: Sign? {
        signOfTodayOverride ?? catalog.signOfToday()
    }

    private var recentTenTests: RecentTestAggregate? {
        historyStore.recentAggregate(limit: 10)
    }

    private var recentFiveTests: RecentTestAggregate? {
        historyStore.recentAggregate(limit: 5)
    }

    private var examReadinessPercent: Int {
        recentFiveTests?.averagePercent ?? 0
    }

    private var examReadinessLevel: ExamReadinessLevel {
        ExamReadinessLevel.from(percent: examReadinessPercent)
    }

    private var signCoverage: MaterialCoverage {
        signProgressStore.coverage(among: catalog.signs.map(\.id))
    }

    private var questionCoverage: MaterialCoverage {
        questionProgressStore.coverage(among: theoryCatalog.questions.map(\.id))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(l10n.text(.tabHome))
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.appBlue)
                .frame(maxWidth: .infinity)
                .padding(.top, 28)
                .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 28) {
                    quickActionsSection
                    signOfTodaySection
                    examReadinessSection
                    testStatisticsSection
                    materialCoverageSection
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .appRootScreen()
        .appScreenBackground()
    }

    /// TEMP: debug control for sign-of-the-day - delete when no longer needed.
    private var temporaryRandomSignButton: some View {
        Button {
            pickRandomSignOfToday()
        } label: {
            Text(l10n.text(.homeShuffle))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(l10n.text(.homeShuffle))
    }

    private func pickRandomSignOfToday() {
        guard !catalog.signs.isEmpty else { return }
        var pool = catalog.signs
        if pool.count > 1, let current = signOfToday {
            pool = pool.filter { $0.id != current.id }
        }
        signOfTodayOverride = pool.randomElement()
    }

    private func homeSectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(Theme.appBlue)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var quickActionsSection: some View {
        HomeFeaturedCard(cornerRadius: cardCornerRadius) {
            HomeQuickActionsGrid(
                onSignTest: { tabRouter.openSignTest() },
                onQuestionTest: { tabRouter.openQuestionTest() },
                onSimulationTest: { tabRouter.openSimulationTest() },
                onPracticeSigns: { tabRouter.openPracticeSigns() },
                onPracticeQuestions: { tabRouter.openPracticeQuestions() }
            )
        }
    }

    @ViewBuilder
    private var signOfTodaySection: some View {
        VStack(spacing: 14) {
            homeSectionTitle(l10n.text(.homeSignOfToday))

            if let error = catalog.loadError {
                HomeFeaturedCard(cornerRadius: cardCornerRadius) {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                }
            } else if let sign = signOfToday {
                signOfTodayCardContent(sign: sign)
            } else {
                HomeFeaturedCard(cornerRadius: cardCornerRadius) {
                    Text(l10n.text(.homeNoSignsLoaded))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func signOfTodayCardContent(sign: Sign) -> some View {
        SignSummaryCard(sign: sign, maxImageSide: 120, nameLineLimit: 1, imageShadow: true)
            .overlay(alignment: .topLeading) {
                temporaryRandomSignButton
                    .padding(ListCardStyle.rowHorizontalPadding)
                    .padding(.top, 6)
                    .padding(.leading, 10)
            }
            .overlay(alignment: .topTrailing) {
                NavigationLink {
                    StudyCardView(signs: [sign])
                } label: {
                    Text(l10n.text(.homeInfo))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(l10n.text(.homeInfo))
                .padding(ListCardStyle.rowHorizontalPadding)
                .padding(.top, 6)
                .padding(.trailing, 10)
            }
    }

    @ViewBuilder
    private var materialCoverageSection: some View {
        VStack(spacing: 14) {
            homeSectionTitle(l10n.text(.homeMaterialCoverageTitle))

            HomeCard(elevated: true, cornerRadius: cardCornerRadius) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(l10n.text(.homeMaterialCoverageSubtitle))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MaterialCoverageRow(
                        title: l10n.text(.homeMaterialCoverageSigns),
                        coverage: signCoverage
                    )

                    MaterialCoverageRow(
                        title: l10n.text(.homeMaterialCoverageQuestions),
                        coverage: questionCoverage
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var examReadinessSection: some View {
        VStack(spacing: 14) {
            homeSectionTitle(l10n.text(.homeExamReadinessTitle))

            HomeFeaturedCard(cornerRadius: cardCornerRadius) {
                ExamReadinessIndicator(
                    percent: examReadinessPercent,
                    level: examReadinessLevel,
                    hasTests: recentFiveTests != nil
                )
            }
        }
    }

    @ViewBuilder
    private var testStatisticsSection: some View {
        VStack(spacing: 14) {
            homeSectionTitle(l10n.text(.homeTestStatistics))

            HomeCard(elevated: true, cornerRadius: cardCornerRadius) {
                if historyStore.testsCompleted == 0 {
                    VStack(spacing: 8) {
                        Image(systemName: "list.clipboard")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text(l10n.text(.homeNoTestsYet))
                            .font(.subheadline.weight(.medium))
                        Text(l10n.text(.homeTakePracticeTest))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        if let last = historyStore.lastEntry() {
                            statTile(title: l10n.text(.homeLastTest)) {
                                Text("\(last.percentCorrect)%")
                                    .foregroundStyle(TestScoreStyle.foregroundStyle(for: last.percentCorrect))
                            }
                        }
                        if let recent = recentTenTests {
                            statTile(title: l10n.text(.homeRecentAverage)) {
                                Text("\(recent.averagePercent)%")
                                    .foregroundStyle(TestScoreStyle.foregroundStyle(for: recent.averagePercent))
                            }
                        }
                        statTile(
                            title: l10n.text(.homeTestsTaken),
                            value: "\(historyStore.testsCompleted)"
                        )
                        if let best = historyStore.bestPercent() {
                            statTile(title: l10n.text(.homeBestScore)) {
                                Text("\(best)%")
                                    .foregroundStyle(TestScoreStyle.foregroundStyle(for: best))
                            }
                        }
                    }
                }
            }
        }
    }

    private func statTile(title: String, value: String) -> some View {
        statTile(title: title) {
            Text(value)
        }
    }

    private func statTile<Value: View>(title: String, @ViewBuilder value: () -> Value) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            value()
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.green.opacity(0.1),
            in: RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous)
        )
    }
}

private struct HomeFeaturedCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 16
    @ViewBuilder let content: Content

    private var cardBackground: Color {
        colorScheme == .light ? Color(.systemBackground) : Color(.secondarySystemBackground)
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(colorScheme == .light ? 0.14 : 0.35), radius: 18, x: 0, y: 8)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        HomeTabView()
    }
    .environment(SignCatalog.shared)
    .environment(TheoryQuestionCatalog.shared)
    .environment(SignProgressStore.shared)
    .environment(TheoryQuestionProgressStore.shared)
    .environment(TestHistoryStore.shared)
    .environment(DrivingLicenseProgressStore.shared)
    .environment(AppTabRouter.shared)
    .environment(LocalizationManager.shared)
}
