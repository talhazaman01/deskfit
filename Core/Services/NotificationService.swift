import Foundation
import UserNotifications

actor NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    // MARK: - Permission

    func requestPermission() async -> Bool {
        AnalyticsService.shared.track(.notificationPermissionRequested)

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            AnalyticsService.shared.track(.notificationPermissionResult(granted: granted))
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - Category Setup

    nonisolated func setupNotificationCategories() {
        let startAction = UNNotificationAction(
            identifier: NotificationAction.startNow.rawValue,
            title: "Start Now",
            options: [.foreground]
        )

        let snooze15Action = UNNotificationAction(
            identifier: NotificationAction.snooze15.rawValue,
            title: "Snooze 15 min",
            options: []
        )

        let snooze60Action = UNNotificationAction(
            identifier: NotificationAction.snooze60.rawValue,
            title: "In a meeting (1 hr)",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: NotificationAction.categoryIdentifier,
            actions: [startAction, snooze15Action, snooze60Action],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Scheduling

    func scheduleReminders(
        frequency: ReminderFrequency,
        workStartMinutes: Int,
        workEndMinutes: Int
    ) async {
        await cancelAllReminders()

        guard frequency != .off else { return }

        let times = calculateReminderTimes(
            frequency: frequency,
            workStartMinutes: workStartMinutes,
            workEndMinutes: workEndMinutes
        )

        for (index, minutes) in times.enumerated() {
            await scheduleReminderAt(minutesSinceMidnight: minutes, identifier: "deskfit_reminder_\(index)")
        }
    }

    private func calculateReminderTimes(
        frequency: ReminderFrequency,
        workStartMinutes: Int,
        workEndMinutes: Int
    ) -> [Int] {
        guard workEndMinutes > workStartMinutes else { return [] }

        switch frequency {
        case .hourly:
            var times: [Int] = []
            var current = workStartMinutes
            while current < workEndMinutes {
                times.append(current)
                current += 60
            }
            return times

        case .every2Hours:
            var times: [Int] = []
            var current = workStartMinutes
            while current < workEndMinutes {
                times.append(current)
                current += 120
            }
            return times

        case .threeDaily:
            let workDuration = workEndMinutes - workStartMinutes
            let interval = workDuration / 4
            return [
                workStartMinutes + interval,
                workStartMinutes + interval * 2,
                workStartMinutes + interval * 3
            ]

        case .off:
            return []
        }
    }

    private func scheduleReminderAt(minutesSinceMidnight: Int, identifier: String) async {
        let content = UNMutableNotificationContent()
        content.title = "Time for a quick reset"
        content.body = randomReminderBody()
        content.sound = .default
        content.categoryIdentifier = NotificationAction.categoryIdentifier
        content.userInfo = ["deepLink": "deskfit://start-session"]

        var dateComponents = DateComponents()
        dateComponents.hour = minutesSinceMidnight / 60
        dateComponents.minute = minutesSinceMidnight % 60

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule reminder: \(error)")
        }
    }

    private func randomReminderBody() -> String {
        let bodies = [
            "2 minutes for your neck and shoulders?",
            "Quick desk break? Your body will thank you.",
            "Time to move and reset.",
            "A quick stretch goes a long way.",
            "Your desk break is ready.",
            "Take a moment to reset your posture.",
            "2 minutes. No equipment. Let's go."
        ]
        return bodies.randomElement() ?? bodies[0]
    }

    // MARK: - Snooze

    func scheduleSnooze(minutes: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Ready for your reset?"
        content.body = "Your snoozed break is waiting"
        content.sound = .default
        content.categoryIdentifier = NotificationAction.categoryIdentifier
        content.userInfo = ["deepLink": "deskfit://start-session"]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "deskfit_snooze_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            AnalyticsService.shared.track(.reminderSnooze(durationMinutes: minutes))
        } catch {
            print("Failed to schedule snooze: \(error)")
        }
    }

    // MARK: - Cancel

    func cancelAllReminders() async {
        center.removeAllPendingNotificationRequests()
    }

    func cancelReminder(identifier: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
