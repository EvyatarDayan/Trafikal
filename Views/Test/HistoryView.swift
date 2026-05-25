//
//  HistoryView.swift
//  Trafikal
//

import SwiftUI

struct HistoryView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(TestHistoryStore.self) private var historyStore

    let initialFilter: HistoryFilter

    @State private var filter: HistoryFilter
    @State private var selectedEntry: TestHistoryEntry?

    init(initialFilter: HistoryFilter = .all) {
        self.initialFilter = initialFilter
        _filter = State(initialValue: initialFilter)
    }

    private var filteredEntries: [TestHistoryEntry] {
        historyStore.entries(filter: filter)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: l10n.text(.historyTitle),
                subtitle: l10n.text(.historyCompletedTests),
                showsBackButton: true
            )

            Picker("", selection: $filter) {
                ForEach(HistoryFilter.allCases) { option in
                    Text(option.label(using: l10n)).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 12)

            if historyStore.entries.isEmpty {
                emptyState(
                    title: l10n.text(.historyEmptyTitle),
                    message: l10n.text(.historyEmptyMessage)
                )
            } else if filteredEntries.isEmpty {
                emptyState(
                    title: l10n.text(.historyEmptyFilteredTitle),
                    message: l10n.text(.historyEmptyFilteredMessage)
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEntries) { entry in
                            Button {
                                selectedEntry = entry
                            } label: {
                                TestHistoryRowView(entry: entry, colorScheme: colorScheme, l10n: l10n)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .appScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedEntry) { entry in
            TestHistoryDetailSheet(entry: entry, l10n: l10n)
        }
    }

    private func emptyState(title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TestHistoryRowView: View {
    let entry: TestHistoryEntry
    let colorScheme: ColorScheme
    let l10n: LocalizationManager

    private let cornerRadius: CGFloat = 12

    private var rowBackground: Color {
        colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            scoreBadge

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title(using: l10n))
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(entry.detail(using: l10n))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedDate(entry.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formattedTime(entry.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(rowBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }

    private var scoreBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(TestScoreStyle.badgeBackground(for: entry.percentCorrect))
                .frame(width: 50, height: 50)
            Text("\(entry.percentCorrect)%")
                .font(.caption.weight(.bold))
                .foregroundStyle(TestScoreStyle.foregroundStyle(for: entry.percentCorrect))
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = l10n.locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = l10n.locale
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct TestHistoryDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: TestHistoryEntry
    let l10n: LocalizationManager

    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.locale = l10n.locale
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 14) {
                    Text(entry.title(using: l10n))
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)

                    Rectangle()
                        .fill(Color.primary.opacity(0.35))
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)

                    Text(entry.detail(using: l10n))
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text(l10n.text(.historyPercentCorrect, entry.percentCorrect))
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(formattedDateTime)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }

            Button(l10n.text(.historyGotIt)) {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 28)
        .padding(.top, 32)
        .padding(.bottom, 16)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .environment(TestHistoryStore.shared)
    .environment(LocalizationManager.shared)
}
