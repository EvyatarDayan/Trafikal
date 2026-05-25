//
//  HomeTabView.swift
//  Trafikal
//

import SwiftUI

struct HomeTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(SignCatalog.self) private var catalog
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

    var body: some View {
        VStack(spacing: 0) {
            pageHeader

            ScrollView {
                VStack(spacing: 28) {
                    signOfTodaySection
                    testStatisticsSection
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .appRootScreen()
        .appScreenBackground()
    }

    private var pageHeader: some View {
        ZStack(alignment: .topLeading) {
            homeTitle("Trafikal", font: .system(size: 40, weight: .bold))
                .padding(.top, 13)

            temporaryRandomSignButton
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 15)
        .padding(.bottom, 8)
    }

    /// TEMP: debug control for sign-of-the-day — delete when no longer needed.
    private var temporaryRandomSignButton: some View {
        Button {
            pickRandomSignOfToday()
        } label: {
            Image(systemName: "dice.fill")
                .font(.body.weight(.semibold))
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Random sign of the day")
    }

    private func pickRandomSignOfToday() {
        guard !catalog.signs.isEmpty else { return }
        var pool = catalog.signs
        if pool.count > 1, let current = signOfToday {
            pool = pool.filter { $0.id != current.id }
        }
        signOfTodayOverride = pool.randomElement()
    }

    private func homeTitle(_ text: String, font: Font) -> some View {
        Text(text)
            .font(font)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var signOfTodaySection: some View {
        VStack(spacing: 14) {
            homeTitle("🔥 \(l10n.text(.homeSignOfToday))", font: .title3.bold())

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
        SignSummaryCard(sign: sign, maxImageSide: 150, nameLineLimit: 1, imageShadow: true)
            .overlay(alignment: .topTrailing) {
                NavigationLink {
                    StudyCardView(signs: [sign])
                } label: {
                    Image("Info")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(l10n.text(.homeDetails))
                .padding(ListCardStyle.rowHorizontalPadding)
                .padding(.top, 6)
            }
    }

    @ViewBuilder
    private var testStatisticsSection: some View {
        VStack(spacing: 14) {
            homeTitle(l10n.text(.homeTestStatistics), font: .title3.bold())

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
                    VStack(spacing: 20) {
                        if let recent = recentTenTests {
                            TestResultsPieChart(
                                correct: recent.correctCount,
                                total: recent.totalQuestions,
                                size: 180,
                                dropShadow: true
                            )
                            .frame(maxWidth: .infinity)
                        }

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
            Color(.systemGray5),
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

private struct HomeCard<Content: View>: View {
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

#Preview {
    NavigationStack {
        HomeTabView()
    }
    .environment(SignCatalog.shared)
    .environment(TestHistoryStore.shared)
    .environment(LocalizationManager.shared)
}
