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

// MARK: - Stiffness Time (When user typically feels stiff)

enum StiffnessTime: String, CaseIterable, Identifiable {
    case morning
    case midday
    case evening

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .evening: return "Evening"
        }
    }

    var description: String {
        switch self {
        case .morning: return "Right after I start work"
        case .midday: return "After a few hours at my desk"
        case .evening: return "Toward the end of the day"
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .evening: return "sunset.fill"
        }
    }

    /// Suggested first session type based on when user feels stiff
    var preferredFirstSession: SessionType {
        switch self {
        case .morning: return .morning
        case .midday: return .midday
        case .evening: return .afternoon
        }
    }

    /// Adjusted reminder offset from work start based on stiffness time
    var reminderOffsetMinutes: Int {
        switch self {
        case .morning: return 30      // First reminder 30 min after work start
        case .midday: return 120      // First reminder 2 hours after work start
        case .evening: return 240     // First reminder 4 hours after work start
        }
    }
}

// MARK: - Gender

enum Gender: String, CaseIterable, Identifiable {
    case female
    case male
    case nonBinary = "non_binary"
    case preferNotToSay = "prefer_not_to_say"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .nonBinary: return "Non-binary"
        case .preferNotToSay: return "Prefer not to say"
        }
    }

    var icon: String {
        switch self {
        case .female: return "figure.stand.dress"
        case .male: return "figure.stand"
        case .nonBinary: return "person.fill"
        case .preferNotToSay: return "person.fill.questionmark"
        }
    }
}

// MARK: - Measurement Unit

enum MeasurementUnit: String, CaseIterable {
    case metric
    case imperial

    var heightLabel: String {
        switch self {
        case .metric: return "cm"
        case .imperial: return "ft/in"
        }
    }

    var weightLabel: String {
        switch self {
        case .metric: return "kg"
        case .imperial: return "lb"
        }
    }
}

// MARK: - Age Band (for analytics, not raw DOB)

enum AgeBand: String {
    case teen = "13-17"
    case youngAdult = "18-39"
    case middleAge = "40-59"
    case senior = "60+"

    static func from(age: Int) -> AgeBand {
        switch age {
        case 13...17: return .teen
        case 18...39: return .youngAdult
        case 40...59: return .middleAge
        default: return .senior
        }
    }
}
