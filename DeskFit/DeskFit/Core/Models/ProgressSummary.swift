import Foundation

// MARK: - Progress Summary

/// Weekly progress summary computed from DailyScoreEntry data.
/// Used to power the Progress tab UI.
struct ProgressSummary: Codable, Sendable {
    /// Start date of the week (Monday)
    let weekStartDate: Date

    /// Average posture score for the week (0-100)
    let weeklyAverageScore: Int

    /// Total sessions completed this week
    let weeklySessionsCompleted: Int

    /// Total minutes of sessions this week
    let weeklyMinutesCompleted: Int

    /// Current streak in days
    let streakDays: Int

    /// Last 7 days of entries (most recent first)
    let last7Days: [DailyScoreEntry]

    /// Generated achievements/wins for the week
    let wins: [ProgressWin]

    // MARK: - Computed Properties

    /// Whether there's enough data to show meaningful progress
    /// Shows progress UI if user has completed at least 1 session (any day with activity)
    var hasEnoughData: Bool {
        last7Days.contains { $0.hasActivity }
    }

    /// Days with activity this week
    var activeDaysCount: Int {
        last7Days.filter { $0.hasActivity }.count
    }

    /// Trend direction based on recent scores
    var trend: ProgressTrend {
        guard last7Days.count >= 3 else { return .neutral }

        let recentDays = last7Days.filter { $0.hasActivity }.prefix(5)
        guard recentDays.count >= 2 else { return .neutral }

        let scores = recentDays.map { $0.score }
        let firstHalf = scores.prefix(scores.count / 2)
        let secondHalf = scores.suffix(scores.count / 2)

        guard !firstHalf.isEmpty && !secondHalf.isEmpty else { return .neutral }

        let firstAvg = firstHalf.reduce(0, +) / firstHalf.count
        let secondAvg = secondHalf.reduce(0, +) / secondHalf.count

        if secondAvg > firstAvg + 5 {
            return .improving
        } else if secondAvg < firstAvg - 5 {
            return .declining
        }
        return .neutral
    }

    /// Display string for weekly average
    var averageScoreDisplay: String {
        "\(weeklyAverageScore)"
    }

    /// Progress fraction (0.0-1.0) for score ring
    var scoreProgress: Double {
        Double(weeklyAverageScore) / 100.0
    }

    /// Display string for streak
    var streakDisplay: String {
        if streakDays == 0 {
            return "Start your streak"
        } else if streakDays == 1 {
            return "1 day"
        } else {
            return "\(streakDays) days"
        }
    }

    /// Sessions count display
    var sessionsDisplay: String {
        if weeklySessionsCompleted == 0 {
            return "No sessions"
        } else if weeklySessionsCompleted == 1 {
            return "1 session"
        } else {
            return "\(weeklySessionsCompleted) sessions"
        }
    }

    /// Minutes display
    var minutesDisplay: String {
        if weeklyMinutesCompleted == 0 {
            return "0 min"
        } else {
            return "\(weeklyMinutesCompleted) min"
        }
    }

    // MARK: - Initialization

    init(
        weekStartDate: Date,
        weeklyAverageScore: Int,
        weeklySessionsCompleted: Int,
        weeklyMinutesCompleted: Int,
        streakDays: Int,
        last7Days: [DailyScoreEntry],
        wins: [ProgressWin] = []
    ) {
        self.weekStartDate = weekStartDate
        self.weeklyAverageScore = max(0, min(100, weeklyAverageScore))
        self.weeklySessionsCompleted = weeklySessionsCompleted
        self.weeklyMinutesCompleted = weeklyMinutesCompleted
        self.streakDays = streakDays
        self.last7Days = last7Days
        self.wins = wins
    }

    // MARK: - Factory

    /// Create an empty summary for new users
    static func empty() -> ProgressSummary {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        let weekStart = calendar.date(from: components) ?? Date()

        return ProgressSummary(
            weekStartDate: weekStart,
            weeklyAverageScore: 0,
            weeklySessionsCompleted: 0,
            weeklyMinutesCompleted: 0,
            streakDays: 0,
            last7Days: [],
            wins: []
        )
    }
}

// MARK: - Progress Trend

enum ProgressTrend: String, Codable, Sendable {
    case improving
    case neutral
    case declining

    var displayName: String {
        switch self {
        case .improving: return "Trending up"
        case .neutral: return "Steady"
        case .declining: return "Room to grow"
        }
    }

    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .neutral: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    var encouragement: String {
        switch self {
        case .improving: return "Your week is trending up!"
        case .neutral: return "You're maintaining consistency."
        case .declining: return "Small resets can turn it around."
        }
    }
}

// MARK: - Progress Win (Achievement)

/// Auto-generated achievement/win based on progress data
struct ProgressWin: Codable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let earnedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        icon: String = "star.fill",
        earnedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.earnedAt = earnedAt
    }
}

// MARK: - Win Generator

enum WinGenerator {
    /// Generate wins based on progress data
    static func generateWins(
        streakDays: Int,
        weeklySessionsCompleted: Int,
        weeklyAverageScore: Int,
        trend: ProgressTrend,
        focusAreasCovered: Set<String>
    ) -> [ProgressWin] {
        var wins: [ProgressWin] = []

        // Streak milestones
        if streakDays >= 7 {
            wins.append(ProgressWin(
                title: "Week Warrior",
                description: "\(streakDays) days consistent",
                icon: "flame.fill"
            ))
        } else if streakDays >= 3 {
            wins.append(ProgressWin(
                title: "Building Momentum",
                description: "\(streakDays) days in a row",
                icon: "bolt.fill"
            ))
        }

        // Session milestones
        if weeklySessionsCompleted >= 15 {
            wins.append(ProgressWin(
                title: "Reset Champion",
                description: "\(weeklySessionsCompleted) sessions this week",
                icon: "trophy.fill"
            ))
        } else if weeklySessionsCompleted >= 7 {
            wins.append(ProgressWin(
                title: "Active Week",
                description: "\(weeklySessionsCompleted) sessions completed",
                icon: "checkmark.seal.fill"
            ))
        }

        // Score milestone
        if weeklyAverageScore >= 80 {
            wins.append(ProgressWin(
                title: "High Performer",
                description: "Weekly score above 80",
                icon: "star.fill"
            ))
        }

        // Trend win
        if trend == .improving {
            wins.append(ProgressWin(
                title: "On the Rise",
                description: "Your scores are improving",
                icon: "arrow.up.circle.fill"
            ))
        }

        // Focus area coverage
        if focusAreasCovered.count >= 4 {
            wins.append(ProgressWin(
                title: "Well-Rounded",
                description: "Targeting \(focusAreasCovered.count) focus areas",
                icon: "circle.hexagongrid.fill"
            ))
        }

        return wins
    }
}

// MARK: - Sample Data

extension ProgressSummary {
    static let sample = ProgressSummary(
        weekStartDate: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
        weeklyAverageScore: 72,
        weeklySessionsCompleted: 12,
        weeklyMinutesCompleted: 48,
        streakDays: 5,
        last7Days: DailyScoreEntry.sampleWeek,
        wins: [
            ProgressWin(title: "Building Momentum", description: "5 days consistent", icon: "bolt.fill"),
            ProgressWin(title: "Active Week", description: "12 sessions completed", icon: "checkmark.seal.fill")
        ]
    )

    static let newUser = ProgressSummary.empty()
}
