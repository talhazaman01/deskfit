import Foundation

// MARK: - Score Engine

/// Deterministic scoring engine for calculating daily posture scores.
/// Same inputs always produce same outputs for testability.
///
/// Scoring Philosophy:
/// - Motivational: Scores favor positive actions, avoid huge penalties
/// - Achievable: Even minimal effort yields a reasonable score
/// - Capped: Prevents wild swings, always stays 0-100
/// - Transparent: Rules are simple and explainable to users
final class ScoreEngine: Sendable {
    static let shared = ScoreEngine()

    private init() {}

    // MARK: - Scoring Constants

    /// Base score everyone starts with each day
    static let baseScore: Int = 60

    /// Maximum points from sessions per day (prevents gaming)
    static let maxSessionPoints: Int = 25

    /// Points per completed session
    static let pointsPerSession: Int = 8

    /// Maximum bonus from streak
    static let maxStreakBonus: Int = 10

    /// Points per streak day (caps at maxStreakBonus)
    static let pointsPerStreakDay: Int = 2

    /// Bonus for doing session during reported stiffness time
    static let stiffnessTimeMatchBonus: Int = 3

    /// Penalty for high sedentary hours with no sessions
    static let sedentaryNoPenalty: Int = 10

    /// Minimum possible score (floor)
    static let minimumScore: Int = 30

    /// Maximum possible score (ceiling)
    static let maximumScore: Int = 100

    // MARK: - Score Calculation

    /// Calculate the posture score for a day.
    /// This is deterministic - same inputs always produce same output.
    ///
    /// - Parameters:
    ///   - sessionsCompleted: Number of sessions done today
    ///   - minutesCompleted: Total minutes of sessions
    ///   - streakDays: Current streak count
    ///   - stiffnessTimesMatched: Number of sessions done during user's reported stiffness times
    ///   - sedentaryBucket: User's sedentary hours bucket (for penalty calculation)
    ///   - focusAreas: Focus areas covered in sessions
    /// - Returns: Score between 0-100
    func calculateScore(
        sessionsCompleted: Int,
        minutesCompleted: Int,
        streakDays: Int,
        stiffnessTimesMatched: Int = 0,
        sedentaryBucket: SedentaryHoursBucket? = nil,
        focusAreas: [String] = []
    ) -> Int {
        var score = Self.baseScore

        // 1. Session completion bonus (capped)
        let sessionPoints = min(sessionsCompleted * Self.pointsPerSession, Self.maxSessionPoints)
        score += sessionPoints

        // 2. Streak bonus (capped at maxStreakBonus)
        let streakBonus = min(streakDays * Self.pointsPerStreakDay, Self.maxStreakBonus)
        score += streakBonus

        // 3. Stiffness time match bonus
        // Rewards users for doing sessions when they typically feel stiff
        let stiffnessBonus = min(stiffnessTimesMatched * Self.stiffnessTimeMatchBonus, 6)
        score += stiffnessBonus

        // 4. Sedentary penalty (only if no sessions and high sedentary)
        if sessionsCompleted == 0, let bucket = sedentaryBucket {
            let penalty = sedentaryPenalty(for: bucket)
            score -= penalty
        }

        // 5. Focus area variety bonus (small, 1-2 points)
        if focusAreas.count >= 3 {
            score += 2
        } else if focusAreas.count >= 2 {
            score += 1
        }

        // Clamp to valid range
        return max(Self.minimumScore, min(Self.maximumScore, score))
    }

    /// Calculate score for a specific day with full context
    func calculateDailyScore(
        for date: Date,
        sessionsCompleted: Int,
        minutesCompleted: Int,
        focusAreas: [String],
        stiffnessTimesTriggered: [String],
        profile: OnboardingProfileSnapshot?,
        currentStreak: Int
    ) -> DailyScoreEntry {
        // Calculate stiffness time matches
        let userStiffnessTimes = Set(profile?.stiffnessTimes ?? [])
        let matchedTimes = stiffnessTimesTriggered.filter { userStiffnessTimes.contains($0) }

        let score = calculateScore(
            sessionsCompleted: sessionsCompleted,
            minutesCompleted: minutesCompleted,
            streakDays: currentStreak,
            stiffnessTimesMatched: matchedTimes.count,
            sedentaryBucket: profile?.sedentaryHoursBucketEnum,
            focusAreas: focusAreas
        )

        return DailyScoreEntry(
            date: date,
            score: score,
            minutesCompleted: minutesCompleted,
            sessionsCompleted: sessionsCompleted,
            focusAreas: focusAreas,
            stiffnessTimesTriggered: stiffnessTimesTriggered
        )
    }

    // MARK: - Helper Methods

    /// Calculate penalty based on sedentary hours bucket
    private func sedentaryPenalty(for bucket: SedentaryHoursBucket) -> Int {
        switch bucket {
        case .lessThan2, .twoToFour:
            return 0 // No penalty for lower sedentary hours
        case .fourToSix:
            return 3
        case .sixToEight:
            return 6
        case .moreThan8:
            return Self.sedentaryNoPenalty
        }
    }

    /// Determine session time category based on hour
    func sessionTimeCategory(for date: Date) -> StiffnessTime {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return .morning
        case 12..<17:
            return .midday
        default:
            return .evening
        }
    }

    // MARK: - Explanation Generator

    /// Generate a human-readable explanation of a score
    func explainScore(
        score: Int,
        sessionsCompleted: Int,
        streakDays: Int,
        stiffnessTimesMatched: Int
    ) -> String {
        var parts: [String] = []

        parts.append("Base: \(Self.baseScore)")

        if sessionsCompleted > 0 {
            let sessionPoints = min(sessionsCompleted * Self.pointsPerSession, Self.maxSessionPoints)
            parts.append("Sessions: +\(sessionPoints)")
        }

        if streakDays > 0 {
            let streakBonus = min(streakDays * Self.pointsPerStreakDay, Self.maxStreakBonus)
            parts.append("Streak: +\(streakBonus)")
        }

        if stiffnessTimesMatched > 0 {
            let bonus = min(stiffnessTimesMatched * Self.stiffnessTimeMatchBonus, 6)
            parts.append("Timing: +\(bonus)")
        }

        return parts.joined(separator: " • ")
    }
}

// MARK: - Score Projection

extension ScoreEngine {
    /// Project what score would be if user completes a session
    func projectedScoreAfterSession(
        currentScore: Int,
        currentSessions: Int,
        streakDays: Int
    ) -> Int {
        // Simplified projection - just add session points if under cap
        let currentSessionPoints = min(currentSessions * Self.pointsPerSession, Self.maxSessionPoints)
        let newSessionPoints = min((currentSessions + 1) * Self.pointsPerSession, Self.maxSessionPoints)
        let delta = newSessionPoints - currentSessionPoints

        return min(currentScore + delta, Self.maximumScore)
    }

    /// Get motivational message based on projected improvement
    func motivationalMessage(forProjectedGain gain: Int) -> String {
        if gain >= 8 {
            return "One session could boost your score significantly!"
        } else if gain > 0 {
            return "Keep building — small resets add up."
        } else {
            return "You're already at a great score for today!"
        }
    }
}

// MARK: - Weekly Summary Calculator

extension ScoreEngine {
    /// Calculate weekly average from daily entries
    func calculateWeeklyAverage(from entries: [DailyScoreEntry]) -> Int {
        let activeDays = entries.filter { $0.hasActivity }
        guard !activeDays.isEmpty else { return 0 }
        let total = activeDays.reduce(0) { $0 + $1.score }
        return total / activeDays.count
    }

    /// Calculate total sessions from entries
    func calculateTotalSessions(from entries: [DailyScoreEntry]) -> Int {
        entries.reduce(0) { $0 + $1.sessionsCompleted }
    }

    /// Calculate total minutes from entries
    func calculateTotalMinutes(from entries: [DailyScoreEntry]) -> Int {
        entries.reduce(0) { $0 + $1.minutesCompleted }
    }

    /// Get all unique focus areas from entries
    func collectFocusAreas(from entries: [DailyScoreEntry]) -> Set<String> {
        var areas: Set<String> = []
        for entry in entries {
            areas.formUnion(entry.focusAreas)
        }
        return areas
    }
}
