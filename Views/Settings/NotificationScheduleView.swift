//
//  NotificationScheduleView.swift
//  Trafikal
//

import SwiftUI
import UserNotifications

struct NotificationScheduleView: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("dailyNotificationEnabled") private var dailyNotificationEnabled = false
    @AppStorage("dailyNotificationHour") private var dailyNotificationHour = 9
    @AppStorage("dailyNotificationMinute") private var dailyNotificationMinute = 0

    @State private var selectedTime: Date
    @State private var notificationsEnabled: Bool
    @State private var alertMessage: String?

    private var panelBackground: Color {
        colorScheme == .light ? Color(.secondarySystemGroupedBackground) : Color(.systemGray6)
    }

    init() {
        let storedHour = UserDefaults.standard.object(forKey: "dailyNotificationHour") as? Int ?? 9
        let storedMinute = UserDefaults.standard.object(forKey: "dailyNotificationMinute") as? Int ?? 0
        let storedEnabled = UserDefaults.standard.bool(forKey: "dailyNotificationEnabled")
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = storedHour
        components.minute = storedMinute
        _selectedTime = State(initialValue: Calendar.current.date(from: components) ?? Date())
        _notificationsEnabled = State(initialValue: storedEnabled)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(l10n.text(.settingsNotificationsDailyReminder))
                                .foregroundStyle(.primary)
                            Text(l10n.text(.settingsNotificationsDailyReminderSubtitle))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if notificationsEnabled {
                        Divider()
                            .padding(.leading, 16)

                        DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                    }
                }
                .background(panelBackground, in: RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))

                Text(l10n.text(.settingsNotificationsFooter))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)

                Spacer()
            }
            .padding(16)
            .background(Theme.screenBackground.ignoresSafeArea())
            .navigationTitle(l10n.text(.settingsNotificationsNavTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(l10n.text(.settingsCancel)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(l10n.text(.commonDone)) {
                        saveNotificationSettings()
                    }
                }
            }
            .alert(l10n.text(.settingsNotificationsAlertTitle), isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button(l10n.text(.commonOK), role: .cancel) {
                    alertMessage = nil
                }
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func saveNotificationSettings() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        let hour = components.hour ?? 9
        let minute = components.minute ?? 0

        if notificationsEnabled {
            DailyPracticeNotificationScheduler.scheduleDailyReminder(
                hour: hour,
                minute: minute,
                title: l10n.text(.settingsNotificationsContentTitle),
                body: l10n.text(.settingsNotificationsContentBody),
                permissionDeniedMessage: l10n.text(.settingsNotificationsPermissionDenied)
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        dailyNotificationHour = hour
                        dailyNotificationMinute = minute
                        dailyNotificationEnabled = true
                        dismiss()
                    case .failure(let error):
                        dailyNotificationEnabled = false
                        alertMessage = error.localizedDescription
                    }
                }
            }
        } else {
            DailyPracticeNotificationScheduler.cancelDailyReminder()
            dailyNotificationEnabled = false
            dailyNotificationHour = hour
            dailyNotificationMinute = minute
            dismiss()
        }
    }
}

enum DailyPracticeNotificationScheduler {
    private static let reminderIdentifier = "trafikal.daily-practice-reminder"

    static func scheduleDailyReminder(
        hour: Int,
        minute: Int,
        title: String,
        body: String,
        permissionDeniedMessage: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            func finish(_ result: Result<Void, Error>) {
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            if let error {
                finish(.failure(error))
                return
            }

            guard granted else {
                finish(.failure(NotificationScheduleError.permissionDenied(permissionDeniedMessage)))
                return
            }

            center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: reminderIdentifier,
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error {
                    finish(.failure(error))
                } else {
                    finish(.success(()))
                }
            }
        }
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    enum NotificationScheduleError: LocalizedError {
        case permissionDenied(String)

        var errorDescription: String? {
            switch self {
            case .permissionDenied(let message):
                message
            }
        }
    }
}
