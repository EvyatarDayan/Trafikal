//
//  HistoryView.swift
//  Trafikal
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(TestHistoryStore.self) private var historyStore

    @State private var selectedEntry: TestHistoryEntry?

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: "History",
                subtitle: "Completed tests",
                showsBackButton: true
            )

            if historyStore.entries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(historyStore.entries) { entry in
                            Button {
                                selectedEntry = entry
                            } label: {
                                TestHistoryRowView(entry: entry, colorScheme: colorScheme)
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
            TestHistoryDetailSheet(entry: entry)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No tests yet")
                .font(.headline)
            Text("Finish a practice test and your score will appear here.")
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

    private var rowBackground: Color {
        colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            scoreBadge

            VStack(alignment: .leading, spacing: 4) {
                Text("Road sign test")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(entry.detail)
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
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }

    private var scoreBadge: some View {
        ZStack {
            Circle()
                .fill(entry.percentCorrect >= 70 ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                .frame(width: 50, height: 50)
            Text("\(entry.percentCorrect)%")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(entry.percentCorrect >= 70 ? .green : .orange)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct TestHistoryDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: TestHistoryEntry

    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 14) {
                    Text("Road sign test")
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)

                    Rectangle()
                        .fill(Color.primary.opacity(0.35))
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)

                    Text(entry.detail)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("\(entry.percentCorrect)% correct")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(formattedDateTime)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }

            Button("Got it") {
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
}
