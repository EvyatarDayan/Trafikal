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
    @State private var showingMistakes = false

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
                showsBackButton: true,
                backButtonTitle: l10n.text(.commonDone)
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
        .sheet(item: $selectedEntry, onDismiss: { showingMistakes = false }) { entry in
            Group {
                if showingMistakes {
                    TestHistoryMistakesView(entry: entry) {
                        showingMistakes = false
                    }
                } else {
                    TestHistoryDetailSheet(
                        entry: entry,
                        l10n: l10n,
                        onViewMistakes: { showingMistakes = true }
                    )
                }
            }
            .presentationDetents(showingMistakes ? [.large] : [.height(400)])
            .presentationDragIndicator(.visible)
            .presentationBackground {
                (showingMistakes
                    ? Theme.quizScreenBackground(colorScheme: colorScheme)
                    : Theme.screenBackground
                )
                .ignoresSafeArea()
            }
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
                .fill(TestScoreStyle.simulationBadgeBackground(for: entry.percentCorrect))
                .frame(width: 56, height: 56)
            VStack(spacing: 2) {
                Text(l10n.text(entry.passed ? .simulationPassLabel : .simulationFailLabel))
                    .font(.caption2.weight(.bold))
                Text("\(entry.percentCorrect)%")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(colorScheme == .light ? Color.black : Color(.white))
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
    let onViewMistakes: () -> Void

    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.locale = l10n.locale
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 12) {
                Text(entry.title(using: l10n))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.appBlue)
                    .multilineTextAlignment(.center)

                Rectangle()
                    .fill(Color.primary.opacity(0.35))
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 10) {
                Text(formattedDateTime)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TestResultsPieChart(
                    historyDetailCorrect: entry.score,
                    total: entry.totalQuestions
                )
                .padding(.vertical, 12)

                HStack(spacing: 16) {
                    legendDot(
                        color: .green,
                        label: l10n.text(.testCorrectCount, entry.score)
                    )
                    legendDot(
                        color: .red.opacity(0.85),
                        label: l10n.text(.testIncorrectCount, entry.totalQuestions - entry.score)
                    )
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            HStack(spacing: 12) {
                Button(l10n.text(.historyGotIt)) {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button(l10n.text(.historyViewMistakes)) {
                    onViewMistakes()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .disabled(!entry.hasMistakes)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .environment(TestHistoryStore.shared)
    .environment(LocalizationManager.shared)
}
