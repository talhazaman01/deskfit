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

enum StiffnessTime: String, CaseIterable, Identifiable, Codable, Hashable {
    case morning
    case midday
    case evening
    case allDay = "all_day"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .evening: return "Evening"
        case .allDay: return "All day"
        }
    }

    var description: String {
        switch self {
        case .morning: return "Right after I start work"
        case .midday: return "After a few hours at my desk"
        case .evening: return "Toward the end of the day"
        case .allDay: return "It varies throughout my workday"
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .allDay: return "clock.fill"
        }
    }

    /// Suggested first session type based on when user feels stiff
    var preferredFirstSession: SessionType {
        switch self {
        case .morning: return .morning
        case .midday: return .midday
        case .evening: return .afternoon
        case .allDay: return .morning  // Default to morning for all-day coverage
        }
    }

    /// Adjusted reminder offset from work start based on stiffness time
    var reminderOffsetMinutes: Int {
        switch self {
        case .morning: return 30      // First reminder 30 min after work start
        case .midday: return 120      // First reminder 2 hours after work start
        case .evening: return 240     // First reminder 4 hours after work start
        case .allDay: return 60       // First reminder 1 hour after work start (balanced)
        }
    }

    /// Individual time cases (excludes allDay) for UI ordering
    static var individualCases: [StiffnessTime] {
        [.morning, .midday, .evening]
    }

    /// Pure function to toggle a stiffness time with proper mutual exclusivity rules
    /// - If tapped == .allDay: returns [.allDay] (exclusive)
    /// - If tapped is individual time: removes .allDay if present, then toggles the tapped time
    static func toggle(_ tapped: StiffnessTime, in current: Set<StiffnessTime>) -> Set<StiffnessTime> {
        if tapped == .allDay {
            // Tapping "All day" always sets selection to just [.allDay]
            return [.allDay]
        } else {
            // Tapping an individual time
            var newSet = current
            // Remove .allDay if present (individual times are mutually exclusive with .allDay)
            newSet.remove(.allDay)
            // Toggle the tapped time
            if newSet.contains(tapped) {
                newSet.remove(tapped)
            } else {
                newSet.insert(tapped)
            }
            return newSet
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

// MARK: - Sedentary Hours Bucket

enum SedentaryHoursBucket: String, CaseIterable, Identifiable {
    case lessThan2 = "less_than_2"
    case twoToFour = "2_to_4"
    case fourToSix = "4_to_6"
    case sixToEight = "6_to_8"
    case moreThan8 = "more_than_8"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lessThan2: return "< 2"
        case .twoToFour: return "2–4"
        case .fourToSix: return "4–6"
        case .sixToEight: return "6–8"
        case .moreThan8: return "8+"
        }
    }

    var description: String {
        switch self {
        case .lessThan2: return "hours"
        case .twoToFour: return "hours"
        case .fourToSix: return "hours"
        case .sixToEight: return "hours"
        case .moreThan8: return "hours"
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

// MARK: - Pain/Discomfort Areas

enum PainArea: String, CaseIterable, Identifiable, Codable {
    case neck
    case shoulders
    case upperBack = "upper_back"
    case lowerBack = "lower_back"
    case wrists
    case hips
    case headaches
    case eyeStrain = "eye_strain"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .neck: return "Neck"
        case .shoulders: return "Shoulders"
        case .upperBack: return "Upper Back"
        case .lowerBack: return "Lower Back"
        case .wrists: return "Wrists"
        case .hips: return "Hips"
        case .headaches: return "Headaches"
        case .eyeStrain: return "Eye Strain"
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
        case .headaches: return "brain.head.profile"
        case .eyeStrain: return "eye"
        }
    }

    var description: String {
        switch self {
        case .neck: return "Stiffness or discomfort in the neck"
        case .shoulders: return "Tension or tightness in shoulders"
        case .upperBack: return "Aching between shoulder blades"
        case .lowerBack: return "Discomfort in the lower spine"
        case .wrists: return "Strain from typing or mouse use"
        case .hips: return "Tight or stiff hip flexors"
        case .headaches: return "Tension headaches from desk work"
        case .eyeStrain: return "Tired or strained eyes"
        }
    }

    /// Map to related exercise focus areas
    var relatedFocusAreas: [FocusArea] {
        switch self {
        case .neck: return [.neck]
        case .shoulders: return [.shoulders]
        case .upperBack: return [.upperBack, .shoulders]
        case .lowerBack: return [.lowerBack, .hips]
        case .wrists: return [.wrists]
        case .hips: return [.hips, .lowerBack]
        case .headaches: return [.neck, .shoulders] // Tension headaches
        case .eyeStrain: return [.neck] // Often related to forward head posture
        }
    }
}

// MARK: - Posture Issues

enum PostureIssue: String, CaseIterable, Identifiable, Codable {
    case forwardHead = "forward_head"
    case roundedShoulders = "rounded_shoulders"
    case slouching
    case textNeck = "text_neck"
    case unevenHips = "uneven_hips"
    case anteriorPelvicTilt = "anterior_pelvic_tilt"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .forwardHead: return "Forward Head"
        case .roundedShoulders: return "Rounded Shoulders"
        case .slouching: return "Slouching"
        case .textNeck: return "Text Neck"
        case .unevenHips: return "Uneven Hips"
        case .anteriorPelvicTilt: return "Lower Back Arch"
        }
    }

    var icon: String {
        switch self {
        case .forwardHead: return "person.crop.circle.badge.exclamationmark"
        case .roundedShoulders: return "figure.roll"
        case .slouching: return "chair.lounge"
        case .textNeck: return "iphone"
        case .unevenHips: return "figure.walk"
        case .anteriorPelvicTilt: return "figure.stand"
        }
    }

    var description: String {
        switch self {
        case .forwardHead: return "Head juts forward from the body"
        case .roundedShoulders: return "Shoulders roll inward"
        case .slouching: return "General poor seated posture"
        case .textNeck: return "Neck strain from looking at devices"
        case .unevenHips: return "One hip higher than the other"
        case .anteriorPelvicTilt: return "Excessive lower back curve"
        }
    }

    /// Map to related exercise focus areas
    var relatedFocusAreas: [FocusArea] {
        switch self {
        case .forwardHead: return [.neck, .upperBack]
        case .roundedShoulders: return [.shoulders, .upperBack]
        case .slouching: return [.upperBack, .lowerBack]
        case .textNeck: return [.neck, .shoulders]
        case .unevenHips: return [.hips, .lowerBack]
        case .anteriorPelvicTilt: return [.hips, .lowerBack]
        }
    }

    /// Map to exercise issue tags
    var exerciseIssueTags: [ExerciseIssueTag] {
        switch self {
        case .forwardHead: return [.forwardHead, .textNeck]
        case .roundedShoulders: return [.roundedShoulders]
        case .slouching: return [.slouching, .roundedShoulders]
        case .textNeck: return [.textNeck, .forwardHead]
        case .unevenHips: return [.unevenHips]
        case .anteriorPelvicTilt: return [.anteriorPelvicTilt]
        }
    }
}

// MARK: - Work Type

enum WorkType: String, CaseIterable, Identifiable, Codable {
    case deskOffice = "desk_office"
    case deskHome = "desk_home"
    case hybrid
    case standing
    case mixed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .deskOffice: return "Office Desk Job"
        case .deskHome: return "Work From Home"
        case .hybrid: return "Hybrid"
        case .standing: return "Standing Desk"
        case .mixed: return "Mixed (Desk + Moving)"
        }
    }

    var icon: String {
        switch self {
        case .deskOffice: return "building.2"
        case .deskHome: return "house"
        case .hybrid: return "arrow.left.arrow.right"
        case .standing: return "figure.stand"
        case .mixed: return "figure.walk"
        }
    }

    var description: String {
        switch self {
        case .deskOffice: return "Sitting at a desk in an office"
        case .deskHome: return "Sitting at a desk at home"
        case .hybrid: return "Mix of office and home"
        case .standing: return "Using a standing desk"
        case .mixed: return "Some desk work, some moving around"
        }
    }
}

// MARK: - Exercise Frequency

enum ExerciseFrequency: String, CaseIterable, Identifiable, Codable {
    case rarely
    case onceWeek = "once_week"
    case twoThreeWeek = "two_three_week"
    case fourPlusWeek = "four_plus_week"
    case daily

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rarely: return "Rarely"
        case .onceWeek: return "Once a week"
        case .twoThreeWeek: return "2-3 times/week"
        case .fourPlusWeek: return "4+ times/week"
        case .daily: return "Daily"
        }
    }

    var icon: String {
        switch self {
        case .rarely: return "zzz"
        case .onceWeek: return "1.circle"
        case .twoThreeWeek: return "2.circle"
        case .fourPlusWeek: return "4.circle"
        case .daily: return "calendar"
        }
    }

    var description: String {
        switch self {
        case .rarely: return "Little to no regular exercise"
        case .onceWeek: return "Light activity once per week"
        case .twoThreeWeek: return "Moderate activity level"
        case .fourPlusWeek: return "Active lifestyle"
        case .daily: return "Very active, daily exercise"
        }
    }

    /// Suggested starting difficulty based on exercise frequency
    var suggestedDifficulty: ExerciseDifficulty {
        switch self {
        case .rarely: return .easy
        case .onceWeek: return .easy
        case .twoThreeWeek: return .medium
        case .fourPlusWeek: return .medium
        case .daily: return .medium
        }
    }
}

// MARK: - Motivation Level

enum MotivationLevel: String, CaseIterable, Identifiable, Codable {
    case curious
    case ready
    case veryMotivated = "very_motivated"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .curious: return "Just Curious"
        case .ready: return "Ready to Start"
        case .veryMotivated: return "Very Motivated"
        }
    }

    var icon: String {
        switch self {
        case .curious: return "questionmark.circle"
        case .ready: return "checkmark.circle"
        case .veryMotivated: return "flame"
        }
    }

    var description: String {
        switch self {
        case .curious: return "I want to explore and see what this is about"
        case .ready: return "I'm committed to building better habits"
        case .veryMotivated: return "I'm eager to make a real change"
        }
    }

    /// Affects progression speed and session difficulty
    var progressionMultiplier: Double {
        switch self {
        case .curious: return 0.8  // Slower, gentler progression
        case .ready: return 1.0   // Standard progression
        case .veryMotivated: return 1.2  // Faster progression
        }
    }
}

// MARK: - Exercise Tags (for enhanced exercise selection)

enum ExerciseIssueTag: String, CaseIterable, Identifiable, Codable {
    case forwardHead = "forward_head"
    case roundedShoulders = "rounded_shoulders"
    case slouching
    case textNeck = "text_neck"
    case unevenHips = "uneven_hips"
    case anteriorPelvicTilt = "anterior_pelvic_tilt"

    var id: String { rawValue }
}

enum ExerciseIntentTag: String, CaseIterable, Identifiable, Codable {
    case mobility
    case strengthening
    case activation
    case breathing
    case decompression
    case stretching

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mobility: return "Mobility"
        case .strengthening: return "Strengthening"
        case .activation: return "Activation"
        case .breathing: return "Breathing"
        case .decompression: return "Decompression"
        case .stretching: return "Stretching"
        }
    }
}

enum ExerciseContextTag: String, CaseIterable, Identifiable, Codable {
    case desk
    case morning
    case midday
    case evening
    case microbreak
    case standing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .desk: return "At Desk"
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .evening: return "Evening"
        case .microbreak: return "Quick Break"
        case .standing: return "Standing"
        }
    }
}

enum ExerciseEquipment: String, CaseIterable, Identifiable, Codable {
    case none
    case chair
    case wall
    case doorway
    case desk

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "No Equipment"
        case .chair: return "Chair"
        case .wall: return "Wall"
        case .doorway: return "Doorway"
        case .desk: return "Desk"
        }
    }
}

enum ExerciseDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var sortOrder: Int {
        switch self {
        case .easy: return 0
        case .medium: return 1
        case .hard: return 2
        }
    }
}
