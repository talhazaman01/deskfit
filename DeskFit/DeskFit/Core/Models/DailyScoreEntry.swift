import Foundation

// MARK: - Daily Score Entry

/// Represents a single day's posture/progress data.
/// Stored locally to track progress over time.
struct DailyScoreEntry: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let date: Date

    /// Posture score (0-100) calculated by ScoreEngine
    let score: Int

    /// Total minutes of sessions completed on this day
    let minutesCompleted: Int

    /// Number of sessions completed on this day
    let sessionsCompleted: Int

    /// Focus areas targeted during sessions (e.g., ["neck", "shoulders"])
    let focusAreas: [String]

    /// Stiffness times when sessions were done (optional, for insight matching)
    let stiffnessTimesTriggered: [String]

    /// Optional user notes for the day
    let notes: String?

    /// When this entry was last updated
    let updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date,
        score: Int,
        minutesCompleted: Int,
        sessionsCompleted: Int,
        focusAreas: [String],
        stiffnessTimesTriggered: [String] = [],
        notes: String? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.score = max(0, min(100, score))
        self.minutesCompleted = minutesCompleted
        self.sessionsCompleted = sessionsCompleted
        self.focusAreas = focusAreas
        self.stiffnessTimesTriggered = stiffnessTimesTriggered
        self.notes = notes
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties

    /// Display-friendly date string (e.g., "Mon, Jan 6")
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    /// Short display date (e.g., "Mon")
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    /// Day number (e.g., "6")
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    /// Score display category
    var scoreCategory: ScoreDisplayCategory {
        ScoreDisplayCategory.from(score: score)
    }

    /// Focus areas as display strings
    var focusAreasDisplay: [String] {
        focusAreas.compactMap { raw in
            FocusArea(rawValue: raw)?.displayName
        }
    }

    /// Whether this is today's entry
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Whether this entry has any completed sessions
    var hasActivity: Bool {
        sessionsCompleted > 0
    }
}

// MARK: - Score Display Category

/// Categories for displaying score with appropriate messaging
enum ScoreDisplayCategory: String, Codable, Sendable {
    case excellent
    case good
    case building
    case starting

    var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .building: return "Building"
        case .starting: return "Starting"
        }
    }

    var encouragement: String {
        switch self {
        case .excellent: return "Outstanding consistency!"
        case .good: return "Keep up the great work!"
        case .building: return "You're building momentum."
        case .starting: return "Every reset counts."
        }
    }

    static func from(score: Int) -> ScoreDisplayCategory {
        switch score {
        case 85...100: return .excellent
        case 70..<85: return .good
        case 50..<70: return .building
        default: return .starting
        }
    }
}

// MARK: - Sample Data for Previews

extension DailyScoreEntry {
    static let sample = DailyScoreEntry(
        date: Date(),
        score: 75,
        minutesCompleted: 12,
        sessionsCompleted: 3,
        focusAreas: ["neck", "shoulders", "upper_back"],
        stiffnessTimesTriggered: ["morning", "midday"]
    )

    static let sampleWeek: [DailyScoreEntry] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let score = dayOffset == 0 ? 0 : Int.random(in: 55...95)
            let sessions = dayOffset == 0 ? 0 : Int.random(in: 1...3)

            return DailyScoreEntry(
                date: date,
                score: score,
                minutesCompleted: sessions * 4,
                sessionsCompleted: sessions,
                focusAreas: ["neck", "shoulders"],
                stiffnessTimesTriggered: dayOffset % 2 == 0 ? ["morning"] : ["midday"]
            )
        }.reversed()
    }()
}
