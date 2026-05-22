//
//  HomeTabView.swift
//  Trafikal
//

import SwiftUI

struct HomeTabView: View {
    @Environment(SignCatalog.self) private var catalog
    @Environment(TestHistoryStore.self) private var historyStore

    private var signOfToday: Sign? {
        catalog.signOfToday()
    }

    var body: some View {
        VStack(spacing: 0) {
            pageHeader

            ScrollView {
                VStack(spacing: 16) {
                    signOfTodaySection
                    testStatisticsSection
                    comingSoonSection
                }
                .padding()
            }
        }
        .appRootScreen()
        .appScreenBackground()
    }

    private var pageHeader: some View {
        VStack(spacing: 4) {
            Text("Home")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("Your daily sign and test progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var signOfTodaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sign of today")
                .font(.headline)

            if let error = catalog.loadError {
                HomeCard {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            } else if let sign = signOfToday {
                HomeCard {
                    VStack(spacing: 16) {
                        SignImageView(sign: sign, maxSide: 120)

                        VStack(spacing: 6) {
                            Text(sign.code)
                                .font(.caption.bold())
                                .foregroundStyle(sign.category.accentColor)
                            Text(sign.name)
                                .font(.title3.bold())
                                .multilineTextAlignment(.center)
                            Text(sign.meaning)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(4)
                        }

                        NavigationLink {
                            StudyCardView(signs: [sign])
                        } label: {
                            Text("Study this sign")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                HomeCard {
                    Text("No signs loaded yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var testStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test statistics")
                .font(.headline)

            HomeCard {
                if historyStore.testsCompleted == 0 {
                    VStack(spacing: 8) {
                        Image(systemName: "list.clipboard")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("No tests completed yet")
                            .font(.subheadline.weight(.medium))
                        Text("Take a practice test to see your stats here.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        if let last = historyStore.lastEntry {
                            statTile(
                                title: "Last test",
                                value: last.detail,
                                subtitle: formattedDate(last.date)
                            )
                        }
                        if let average = historyStore.averagePercentRecent {
                            statTile(
                                title: "Recent average",
                                value: "\(average)%",
                                subtitle: "Last \(min(5, historyStore.testsCompleted)) tests"
                            )
                        }
                        statTile(
                            title: "Tests taken",
                            value: "\(historyStore.testsCompleted)",
                            subtitle: "All time"
                        )
                        if let best = historyStore.bestPercent {
                            statTile(
                                title: "Best score",
                                value: "\(best)%",
                                subtitle: "Personal best"
                            )
                        }
                    }
                }
            }
        }
    }

    private var comingSoonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More")
                .font(.headline)

            HomeCard {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("Tips, streaks, and goals are coming soon.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func statTile(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

private struct HomeCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    private var cardBackground: Color {
        colorScheme == .light ? Color(.systemBackground) : Color(.secondarySystemBackground)
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        HomeTabView()
    }
    .environment(SignCatalog.shared)
    .environment(TestHistoryStore.shared)
}
