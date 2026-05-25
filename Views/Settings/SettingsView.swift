//
//  SettingsView.swift
//  Trafikal
//

import SwiftUI

struct SettingsView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("dailyNotificationEnabled") private var dailyNotificationEnabled = false
    @AppStorage("dailyNotificationHour") private var dailyNotificationHour = 9
    @AppStorage("dailyNotificationMinute") private var dailyNotificationMinute = 0
    @Environment(TestHistoryStore.self) private var historyStore

    @State private var showClearHistoryConfirmation = false
    @State private var showingNotificationSettings = false

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            pageHeader

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                        settingsSectionHeader(l10n.text(.settingsPreferences))
                        settingsCard(darkModeRow)
                        settingsCard(languageRow)
                    }

                    VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                        settingsSectionHeader(l10n.text(.settingsNotificationsSection))
                        settingsCard(notificationsRow)
                    }

                    VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                        settingsSectionHeader(l10n.text(.settingsTestHistory))
                        settingsCard(clearHistoryRow)
                    }

                    VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                        settingsSectionHeader(l10n.text(.settingsSupportSection))
                        settingsCard(helpSupportRow)
                        settingsCard(termsPrivacyRow)
                        settingsCard(aboutRow)
                    }
                }
                .padding(.horizontal, ListCardStyle.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
        }
        .appRootScreen()
        .appScreenBackground()
        .alert(l10n.text(.settingsClearAlertTitle), isPresented: $showClearHistoryConfirmation) {
            Button(l10n.text(.settingsCancel), role: .cancel) {}
            Button(l10n.text(.settingsClear), role: .destructive) {
                historyStore.clearAll()
            }
        } message: {
            Text(l10n.text(.settingsClearAlertMessage))
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationScheduleView()
        }
    }

    private var formattedNotificationTime: String {
        var components = DateComponents()
        components.hour = dailyNotificationHour
        components.minute = dailyNotificationMinute

        guard let date = Calendar.current.date(from: components) else {
            return String(format: "%02d:%02d", dailyNotificationHour, dailyNotificationMinute)
        }

        return date.formatted(date: .omitted, time: .shortened)
    }

    private var notificationsRow: some View {
        Button {
            showingNotificationSettings = true
        } label: {
            settingsRow(
                icon: "bell.fill",
                iconColor: .orange,
                title: l10n.text(.settingsNotificationsScheduleTitle),
                subtitle: l10n.text(.settingsNotificationsScheduleSubtitle)
            ) {
                HStack(spacing: 4) {
                    Text(dailyNotificationEnabled ? formattedNotificationTime : l10n.text(.settingsNotificationsOff))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    settingsChevron
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func settingsSectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }

    private func settingsCard<Content: View>(_ content: Content) -> some View {
        content
            .listCardStyle(background: cardBackground, colorScheme: colorScheme)
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

    private var clearHistoryRow: some View {
        Button {
            showClearHistoryConfirmation = true
        } label: {
            settingsRow(
                icon: "trash",
                iconColor: .red,
                title: l10n.text(.settingsClearHistory),
                subtitle: l10n.text(.settingsClearHistorySubtitle)
            ) {
                EmptyView()
            }
        }
        .buttonStyle(.plain)
        .disabled(historyStore.testsCompleted == 0)
        .opacity(historyStore.testsCompleted == 0 ? 0.5 : 1)
    }

    private var helpSupportRow: some View {
        NavigationLink {
            HelpSupportView()
        } label: {
            settingsRow(
                icon: "questionmark.circle",
                iconColor: .blue,
                title: l10n.text(.settingsSupportHelpTitle),
                subtitle: l10n.text(.settingsSupportHelpSubtitle)
            ) {
                settingsChevron
            }
        }
        .buttonStyle(.plain)
    }

    private var termsPrivacyRow: some View {
        NavigationLink {
            TermsPrivacyView()
        } label: {
            settingsRow(
                icon: "doc.text",
                iconColor: .orange,
                title: l10n.text(.settingsSupportTermsTitle),
                subtitle: l10n.text(.settingsSupportTermsSubtitle)
            ) {
                settingsChevron
            }
        }
        .buttonStyle(.plain)
    }

    private var aboutRow: some View {
        NavigationLink {
            AboutView()
        } label: {
            settingsRow(
                icon: "info.circle",
                iconColor: .teal,
                title: l10n.text(.settingsAboutRowTitle),
                subtitle: l10n.text(.settingsAboutRowSubtitle)
            ) {
                settingsChevron
            }
        }
        .buttonStyle(.plain)
    }

    private var settingsChevron: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.tertiary)
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
    NavigationStack {
        SettingsView()
    }
    .environment(TestHistoryStore.shared)
    .environment(LocalizationManager.shared)
}
