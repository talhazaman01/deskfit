import Foundation
import Combine
import SwiftData
import UserNotifications

@MainActor
class HomeViewModel: ObservableObject {
    @Published var nextReminderTime: Date?
    @Published var remindersEnabled: Bool = true
    @Published var todayCompletedMinutes: Int = 0

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Reminder Info

    func updateReminderInfo(profile: UserProfile) async {
        let frequency = ReminderFrequency(rawValue: profile.reminderFrequency) ?? .every2Hours

        if frequency == .off {
            remindersEnabled = false
            nextReminderTime = nil
            return
        }

        remindersEnabled = true

        // Check notification permission
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        guard settings.authorizationStatus == .authorized else {
            remindersEnabled = false
            nextReminderTime = nil
            return
        }

        // Calculate next reminder time
        nextReminderTime = calculateNextReminderTime(
            frequency: frequency,
            workStartMinutes: profile.workStartMinutes,
            workEndMinutes: profile.workEndMinutes
        )
    }

    private func calculateNextReminderTime(
        frequency: ReminderFrequency,
        workStartMinutes: Int,
        workEndMinutes: Int
    ) -> Date? {
        let now = Date()
        let calendar = Calendar.current
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)

        let reminderTimes = calculateReminderTimes(
            frequency: frequency,
            workStartMinutes: workStartMinutes,
            workEndMinutes: workEndMinutes
        )

        // Find the next reminder time after now
        for minutes in reminderTimes {
            if minutes > currentMinutes {
                return Date.fromMinutesSinceMidnight(minutes)
            }
        }

        // If no more reminders today, return first reminder tomorrow
        if let firstReminder = reminderTimes.first {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                let startOfTomorrow = calendar.startOfDay(for: tomorrow)
                return calendar.date(byAdding: .minute, value: firstReminder, to: startOfTomorrow)
            }
        }

        return nil
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

    // MARK: - Today's Minutes

    func calculateTodayMinutes(plan: DailyPlan?) -> Int {
        guard let plan = plan else { return 0 }

        let completedSessions = plan.sessions.filter { $0.isCompleted }
        let totalSeconds = completedSessions.reduce(0) { $0 + $1.durationSeconds }
        return totalSeconds / 60
    }

    // MARK: - Dynamic CTA Text

    func contextualCTATitle(for session: PlannedSession) -> String {
        let minutes = max(1, session.durationSeconds / 60)
        let minuteText = minutes == 1 ? "1 min" : "\(minutes) min"
        return "Start \(session.title) (\(minuteText))"
    }

    // MARK: - Dynamic Pro Upsell

    func proUpsellText(for profile: UserProfile) -> String {
        let focusAreaStrings = profile.focusAreas.compactMap { FocusArea(rawValue: $0)?.displayName }

        if focusAreaStrings.isEmpty {
            return "Unlock personalized daily plans"
        }

        // Show first 2 focus areas
        let displayAreas = focusAreaStrings.prefix(2)
        let areaText = displayAreas.joined(separator: " + ")

        return "Unlock plans for \(areaText)"
    }

    // MARK: - Next Reminder Formatted

    var nextReminderFormatted: String? {
        guard let time = nextReminderTime else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
}
