//
//  SettingsView.swift
//  Trafikal
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(TestHistoryStore.self) private var historyStore

    @State private var showClearHistoryConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            pageHeader

            Form {
                Section {
                    EmptyView()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                Section("Preferences") {
                    darkModeRow
                }

                Section("Test history") {
                    clearHistoryRow
                }

                Section {
                    Text("")
                        .frame(height: 30)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .scrollContentBackground(.hidden)
            .background(Theme.screenBackground)
        }
        .appRootScreen()
        .background(Theme.screenBackground)
        .alert("Clear history?", isPresented: $showClearHistoryConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                historyStore.clearAll()
            }
        } message: {
            Text("This will permanently delete all completed test results. This cannot be undone.")
        }
    }

    private var pageHeader: some View {
        VStack(spacing: 4) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("Customize your app preferences")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 6)
        .background(Theme.screenBackground)
    }

    private var darkModeRow: some View {
        settingsRow(
            icon: "moon.fill",
            iconColor: .purple,
            title: "Dark mode",
            subtitle: "Toggle appearance"
        ) {
            Toggle("", isOn: $isDarkMode)
                .labelsHidden()
                .scaleEffect(0.72, anchor: .trailing)
        }
    }

    private var clearHistorySubtitle: String {
        if historyStore.testsCompleted == 0 {
            return "No completed tests saved"
        }
        let count = historyStore.testsCompleted
        return "Remove \(count) saved test\(count == 1 ? "" : "s")"
    }

    private var clearHistoryRow: some View {
        Button {
            showClearHistoryConfirmation = true
        } label: {
            settingsRow(
                icon: "trash",
                iconColor: .red,
                title: "Clear history",
                subtitle: clearHistorySubtitle
            ) {
                EmptyView()
            }
        }
        .buttonStyle(.plain)
        .disabled(historyStore.testsCompleted == 0)
    }

    private func settingsRow<Trailing: View>(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            trailing()
        }
    }
}

#Preview {
    SettingsView()
        .environment(TestHistoryStore.shared)
}
