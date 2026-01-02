import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var createdAt: Date

    // Onboarding
    var goal: String
    var focusAreas: [String]
    var dailyTimeMinutes: Int

    // Work hours as minutes since midnight (0-1439)
    // e.g., 9:00 AM = 540, 5:00 PM = 1020
    var workStartMinutes: Int
    var workEndMinutes: Int

    var reminderFrequency: String

    // Preferences
    var soundEnabled: Bool
    var hapticsEnabled: Bool

    // Stats
    var currentStreak: Int
    var longestStreak: Int
    var lastSessionDate: Date?
    var totalMinutes: Int
    var totalSessions: Int

    // NOTE: Subscription state is NOT stored here.
    // Use SubscriptionManager.shared.isProUser which derives from StoreKit 2 entitlements.

    // State
    var onboardingCompleted: Bool
    var notificationPermissionAsked: Bool

    init() {
        self.id = UUID()
        self.createdAt = Date()
        self.goal = ""
        self.focusAreas = []
        self.dailyTimeMinutes = 5
        self.workStartMinutes = 540  // 9:00 AM
        self.workEndMinutes = 1020   // 5:00 PM
        self.reminderFrequency = "every_2_hours"
        self.soundEnabled = true
        self.hapticsEnabled = true
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastSessionDate = nil
        self.totalMinutes = 0
        self.totalSessions = 0
        self.onboardingCompleted = false
        self.notificationPermissionAsked = false
    }

    // Convenience computed properties
    var workStartHour: Int { workStartMinutes / 60 }
    var workStartMinute: Int { workStartMinutes % 60 }
    var workEndHour: Int { workEndMinutes / 60 }
    var workEndMinute: Int { workEndMinutes % 60 }

    var workStartTime: Date {
        Calendar.current.date(bySettingHour: workStartHour, minute: workStartMinute, second: 0, of: Date()) ?? Date()
    }

    var workEndTime: Date {
        Calendar.current.date(bySettingHour: workEndHour, minute: workEndMinute, second: 0, of: Date()) ?? Date()
    }
}

extension Date {
    var minutesSinceMidnight: Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    static func fromMinutesSinceMidnight(_ minutes: Int) -> Date {
        let hour = minutes / 60
        let minute = minutes % 60
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
