//
//  SettingsView.swift
//  Trafikal
//

import SwiftUI

struct SettingsView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.colorScheme) private var colorScheme
    @Environment(SignCatalog.self) private var signCatalog
    @Environment(TheoryQuestionCatalog.self) private var theoryCatalog
    @Environment(FavoritesStore.self) private var favoritesStore
    @Environment(TestHistoryStore.self) private var historyStore
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("dailyNotificationEnabled") private var dailyNotificationEnabled = false
    @AppStorage("dailyNotificationHour") private var dailyNotificationHour = 9
    @AppStorage("dailyNotificationMinute") private var dailyNotificationMinute = 0

    @State private var showClearHistoryConfirmation = false
    @State private var showingNotificationSettings = false
    @State private var showingExportFavoritesSheet = false
    @State private var exportItems: [Any] = []
    @State private var isExportingFavorites = false
    @State private var exportFavoritesMessage: String?

    private var cardBackground: Color {
        ListCardStyle.cardBackground(colorScheme: colorScheme)
    }

    private var hasFavorites: Bool {
        !favoritesStore.signCodes.isEmpty || !favoritesStore.questionIDs.isEmpty
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
                        settingsCard(notificationsRow)
                    }

                    VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                        settingsSectionHeader(l10n.text(.settingsExportSection))
                        settingsCard(exportFavoritesRow)
                    }

                    VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                        settingsSectionHeader(l10n.text(.settingsSupportSection))
                        settingsCard(helpSupportRow)
                        settingsCard(termsPrivacyRow)
                        settingsCard(aboutRow)
                    }

                    VStack(alignment: .leading, spacing: ListCardStyle.rowSpacing) {
                        settingsSectionHeader(l10n.text(.historyTitle))
                        settingsCard(clearHistoryRow)
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
        .sheet(isPresented: $showingExportFavoritesSheet) {
            ShareSheet(activityItems: exportItems)
        }
        .alert(l10n.text(.settingsExportFavoritesAlertTitle), isPresented: Binding(
            get: { exportFavoritesMessage != nil },
            set: { if !$0 { exportFavoritesMessage = nil } }
        )) {
            Button(l10n.text(.commonOK), role: .cancel) {
                exportFavoritesMessage = nil
            }
        } message: {
            Text(exportFavoritesMessage ?? "")
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

    private var exportFavoritesRow: some View {
        Button {
            exportFavorites()
        } label: {
            settingsRow(
                icon: "square.and.arrow.up.fill",
                iconColor: .green,
                title: l10n.text(.settingsExportFavoritesTitle),
                subtitle: l10n.text(.settingsExportFavoritesSubtitle)
            ) {
                settingsChevron
            }
        }
        .buttonStyle(.plain)
        .disabled(!hasFavorites || isExportingFavorites)
        .opacity(hasFavorites ? 1 : 0.5)
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
        Text(l10n.text(.settingsTitle))
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(Theme.appBlue)
            .frame(maxWidth: .infinity, alignment: .center)
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
            Text(l10n.language.flagEmoji)
                .font(.body)
                .frame(width: 28, alignment: .center)
        }
        .menuIndicator(.hidden)
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

    private func exportFavorites() {
        guard hasFavorites else {
            exportFavoritesMessage = l10n.text(.settingsExportFavoritesEmpty)
            return
        }

        isExportingFavorites = true
        let content = makeFavoritesExportContent()
        let fileName = "Trafikal_Favorites_\(FavoritesExporter.dateStamp()).pdf"

        Task {
            do {
                let fileURL = try await Task.detached {
                    try FavoritesExporter.createPDF(content: content, fileName: fileName)
                }.value

                exportItems = [fileURL]
                showingExportFavoritesSheet = true
            } catch {
                exportFavoritesMessage = l10n.text(
                    .settingsExportFavoritesFailed,
                    error.localizedDescription
                )
            }
            isExportingFavorites = false
        }
    }

    private func makeFavoritesExportContent() -> FavoritesExportContent {
        let signs = favoritesStore.favoriteSigns(in: signCatalog)
            .sorted { $0.code.localizedCompare($1.code) == .orderedAscending }
            .map {
                FavoritesSignExportItem(
                    code: $0.code,
                    name: $0.name,
                    category: $0.category.title,
                    meaning: $0.meaning,
                    imagePNGData: FavoritesExporter.pngData(for: $0)
                )
            }

        let questions = favoritesStore.favoriteQuestions(in: theoryCatalog)
            .sorted { $0.id < $1.id }
            .map {
                FavoritesQuestionExportItem(
                    id: $0.id,
                    category: $0.category,
                    question: $0.question,
                    answer: $0.answer,
                    explanation: $0.explanation
                )
            }

        let labels = FavoritesExportContent.Labels(
            documentTitle: l10n.text(.settingsExportFavoritesPDFTitle),
            summaryFormat: l10n.text(.settingsExportFavoritesPDFSummary),
            signsSectionTitle: l10n.text(.tabSigns),
            questionsSectionTitle: l10n.text(.tabQuestions),
            codeLabel: l10n.text(.settingsExportFavoritesPDFCode),
            nameLabel: l10n.text(.settingsExportFavoritesPDFName),
            categoryLabel: l10n.text(.settingsExportFavoritesPDFCategory),
            meaningLabel: l10n.text(.settingsExportFavoritesPDFMeaning),
            questionLabel: l10n.text(.settingsExportFavoritesPDFQuestion),
            answerLabel: l10n.text(.settingsExportFavoritesPDFAnswer),
            explanationLabel: l10n.text(.settingsExportFavoritesPDFExplanation)
        )

        return FavoritesExportContent(
            signs: signs,
            questions: questions,
            labels: labels,
            exportedAt: Date(),
            locale: l10n.locale
        )
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
    .environment(SignCatalog.shared)
    .environment(TheoryQuestionCatalog.shared)
    .environment(FavoritesStore.shared)
    .environment(LocalizationManager.shared)
}
