import Foundation

enum FocusArea: String, CaseIterable, Identifiable {
    case neck
    case shoulders
    case upperBack = "upper_back"
    case lowerBack = "lower_back"
    case wrists
    case hips

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .neck: return "Neck"
        case .shoulders: return "Shoulders"
        case .upperBack: return "Upper Back"
        case .lowerBack: return "Lower Back"
        case .wrists: return "Wrists"
        case .hips: return "Hips"
        }
    }

    var icon: String {
        switch self {
        case .neck: return "figure.stand"
        case .shoulders: return "figure.arms.open"
        case .upperBack: return "figure.roll"
        case .lowerBack: return "figure.flexibility"
        case .wrists: return "hand.raised.fingers.spread"
        case .hips: return "figure.walk"
        }
    }
}

enum UserGoal: String, CaseIterable, Identifiable {
    case moveMore = "move_more"
    case reduceStiffness = "reduce_stiffness"
    case buildHabit = "build_habit"
    case improvePosture = "improve_posture"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .moveMore: return "Move More"
        case .reduceStiffness: return "Reduce Stiffness"
        case .buildHabit: return "Build a Habit"
        case .improvePosture: return "Improve Posture"
        }
    }

    var description: String {
        switch self {
        case .moveMore: return "Get more movement into your day"
        case .reduceStiffness: return "Feel more comfortable at your desk"
        case .buildHabit: return "Create a consistent routine"
        case .improvePosture: return "Develop better posture habits"
        }
    }

    var icon: String {
        switch self {
        case .moveMore: return "figure.run"
        case .reduceStiffness: return "figure.flexibility"
        case .buildHabit: return "calendar"
        case .improvePosture: return "figure.stand"
        }
    }
}

enum ReminderFrequency: String, CaseIterable, Identifiable {
    case hourly
    case every2Hours = "every_2_hours"
    case threeDaily = "3x_daily"
    case off

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hourly: return "Every hour"
        case .every2Hours: return "Every 2 hours"
        case .threeDaily: return "3x per day"
        case .off: return "Off"
        }
    }
}

enum SessionFeedback: String, CaseIterable {
    case tooEasy = "too_easy"
    case justRight = "just_right"
    case tooHard = "too_hard"

    var displayName: String {
        switch self {
        case .tooEasy: return "Too Easy"
        case .justRight: return "Just Right"
        case .tooHard: return "Too Hard"
        }
    }

    var icon: String {
        switch self {
        case .tooEasy: return "tortoise.fill"
        case .justRight: return "checkmark.circle.fill"
        case .tooHard: return "flame.fill"
        }
    }
}

enum NotificationAction: String, Sendable {
    case startNow = "START_NOW"
    case snooze15 = "SNOOZE_15"
    case snooze60 = "SNOOZE_60"

    nonisolated static let categoryIdentifier = "DESKFIT_REMINDER"
}

enum SubscriptionStatus: String {
    case free
    case trial
    case subscribed
    case expired
    case unknown
}
