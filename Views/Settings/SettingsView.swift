//
//  SettingsView.swift
//  Trafikal
//

import SwiftUI

struct SettingsView: View {
    @Environment(LocalizationManager.self) private var l10n
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

                Section(l10n.text(.settingsPreferences)) {
                    languageRow
                    darkModeRow
                }

                Section(l10n.text(.settingsTestHistory)) {
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
        .alert(l10n.text(.settingsClearAlertTitle), isPresented: $showClearHistoryConfirmation) {
            Button(l10n.text(.settingsCancel), role: .cancel) {}
            Button(l10n.text(.settingsClear), role: .destructive) {
                historyStore.clearAll()
            }
        } message: {
            Text(l10n.text(.settingsClearAlertMessage))
        }
    }

    private var pageHeader: some View {
        VStack(spacing: 4) {
            Text(l10n.text(.settingsTitle))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(l10n.text(.settingsSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 6)
        .background(Theme.screenBackground)
    }

    private var languageRow: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "globe")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.text(.settingsLanguage))
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(l10n.text(.settingsLanguageSubtitle))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            languageMenuControl
        }
    }

    private var languageMenuControl: some View {
        Menu {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    l10n.setLanguage(language)
                } label: {
                    if l10n.language == language {
                        Label(language.pickerLabel, systemImage: "checkmark")
                    } else {
                        Text(language.pickerLabel)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(l10n.language.flagEmoji)
                    .frame(width: 28, alignment: .center)
                Text(l10n.language.nativeDisplayName)
                    .frame(width: 72, alignment: .leading)
            }
            .font(.body)
            .foregroundStyle(.primary)
        }
        .menuIndicator(.hidden)
        .frame(width: 106, alignment: .leading)
    }

    private var darkModeRow: some View {
        settingsRow(
            icon: "moon.fill",
            iconColor: .purple,
            title: l10n.text(.settingsDarkMode),
            subtitle: l10n.text(.settingsDarkModeSubtitle)
        ) {
            Toggle("", isOn: $isDarkMode)
                .labelsHidden()
                .scaleEffect(0.72, anchor: .trailing)
        }
    }

    private var clearHistorySubtitle: String {
        if historyStore.testsCompleted == 0 {
            return l10n.text(.settingsNoTestsSaved)
        }
        let count = historyStore.testsCompleted
        if count == 1 {
            return l10n.text(.settingsRemoveTestsOne)
        }
        return l10n.text(.settingsRemoveTests, count)
    }

    private var clearHistoryRow: some View {
        Button {
            showClearHistoryConfirmation = true
        } label: {
            settingsRow(
                icon: "trash",
                iconColor: .red,
                title: l10n.text(.settingsClearHistory),
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
        .environment(LocalizationManager.shared)
}
