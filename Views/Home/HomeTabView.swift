//
//  HomeTabView.swift
//  Trafikal
//

import SwiftUI

struct HomeTabView: View {
    @Environment(SignCatalog.self) private var catalog
    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(\.colorScheme) private var colorScheme

    private let horizontalPadding: CGFloat = 24
    private let cardCornerRadius: CGFloat = 16

    private var signOfToday: Sign? {
        catalog.signOfToday()
    }

    var body: some View {
        VStack(spacing: 0) {
            pageHeader

            ScrollView {
                VStack(spacing: 28) {
                    signOfTodaySection
                    testStatisticsSection
                    comingSoonSection
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
        GradientBrandText(text: "Trafikal", font: .system(size: 40, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 15)
            .padding(.bottom, 8)
    }

    private var signOfTodayDateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }

    @ViewBuilder
    private var signOfTodaySection: some View {
        VStack(spacing: 14) {
            Text("🔥 Sign of today — \(signOfTodayDateLabel)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)

            if let error = catalog.loadError {
                HomeFeaturedCard(cornerRadius: cardCornerRadius) {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                }
            } else if let sign = signOfToday {
                HomeFeaturedCard(cornerRadius: cardCornerRadius) {
                    signOfTodayCardContent(sign: sign)
                }
            } else {
                HomeFeaturedCard(cornerRadius: cardCornerRadius) {
                    Text("No signs loaded yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func signOfTodayCardContent(sign: Sign) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                SignImageView(sign: sign, maxSide: 100)

                VStack(spacing: 6) {
                    Text(sign.code)
                        .font(.caption.bold())
                        .foregroundStyle(sign.category.accentColor)

                    Text(sign.name)
                        .font(.title3.bold())
                        .foregroundStyle(Color(red: 0.15, green: 0.4, blue: 0.9))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 16)

            Rectangle()
                .fill(Color(.separator).opacity(0.35))
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 12) {
                Text(sign.meaning)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )

                HStack {
                    Spacer()
                    NavigationLink {
                        StudyCardView(signs: [sign])
                    } label: {
                        Text("Study this sign")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    Spacer()
                }
            }
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var testStatisticsSection: some View {
        VStack(spacing: 14) {
            GradientBrandText(text: "Test statistics", font: .title3.bold())
                .frame(maxWidth: .infinity, alignment: .center)

            HomeCard(elevated: true, cornerRadius: cardCornerRadius) {
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
        VStack(spacing: 12) {
            GradientBrandText(text: "Keep learning", font: .title3.bold())
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Explore Swedish road signs with study cards, categories, and practice tests — all available offline.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            HomeCard(elevated: false, cornerRadius: cardCornerRadius) {
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
}
