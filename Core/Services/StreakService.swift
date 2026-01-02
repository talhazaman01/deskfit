import Foundation
import SwiftData

class StreakService {
    static let shared = StreakService()

    private init() {}

    func updateStreak(for profile: UserProfile, context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())

        guard let lastSession = profile.lastSessionDate else {
            profile.currentStreak = 1
            profile.lastSessionDate = today
            profile.longestStreak = max(profile.longestStreak, 1)
            try? context.save()
            return
        }

        let lastSessionDay = Calendar.current.startOfDay(for: lastSession)
        let daysDifference = Calendar.current.dateComponents([.day], from: lastSessionDay, to: today).day ?? 0

        switch daysDifference {
        case 0:
            break
        case 1:
            profile.currentStreak += 1
            profile.lastSessionDate = today
            profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
        default:
            profile.currentStreak = 1
            profile.lastSessionDate = today
        }

        try? context.save()

        if [3, 7, 14, 30, 60, 100].contains(profile.currentStreak) {
            AnalyticsService.shared.track(.streakMilestone(days: profile.currentStreak))
        }
    }

    func checkAndResetStreak(for profile: UserProfile, context: ModelContext) {
        guard let lastSession = profile.lastSessionDate else { return }

        let today = Calendar.current.startOfDay(for: Date())
        let lastSessionDay = Calendar.current.startOfDay(for: lastSession)
        let daysDifference = Calendar.current.dateComponents([.day], from: lastSessionDay, to: today).day ?? 0

        if daysDifference > 1 {
            profile.currentStreak = 0
            try? context.save()
        }
    }
}
