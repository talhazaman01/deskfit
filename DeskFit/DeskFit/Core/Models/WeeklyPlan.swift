import Foundation
import SwiftData

// MARK: - Weekly Plan (7-day personalized plan)

@Model
final class WeeklyPlan {
    var id: UUID
    var generatedAt: Date
    var schemaVersion: Int
    var version: Int  // Incremented when plan is upgraded due to progression

    // Stored as JSON Data for reliable persistence
    private var dailyPlansJSON: Data
    private var profileSnapshotJSON: Data

    /// Completed sessions this week (for progression tracking)
    var completedSessionsThisWeek: Int

    /// Whether progression has been applied for this week
    var progressionApplied: Bool

    /// The week start date (Monday of the week)
    var weekStartDate: Date

    // MARK: - Computed Properties

    var dailyPlans: [DayPlanItem] {
        get {
            guard !dailyPlansJSON.isEmpty else { return [] }
            do {
                return try JSONDecoder().decode([DayPlanItem].self, from: dailyPlansJSON)
            } catch {
                print("Failed to decode daily plans: \(error)")
                return []
            }
        }
        set {
            do {
                dailyPlansJSON = try JSONEncoder().encode(newValue)
            } catch {
                print("Failed to encode daily plans: \(error)")
                dailyPlansJSON = Data()
            }
        }
    }

    /// Snapshot of the onboarding profile used to generate this plan
    var profileSnapshot: OnboardingProfileSnapshot? {
        get {
            guard !profileSnapshotJSON.isEmpty else { return nil }
            do {
                return try JSONDecoder().decode(OnboardingProfileSnapshot.self, from: profileSnapshotJSON)
            } catch {
                print("Failed to decode profile snapshot: \(error)")
                return nil
            }
        }
        set {
            do {
                if let snapshot = newValue {
                    profileSnapshotJSON = try JSONEncoder().encode(snapshot)
                } else {
                    profileSnapshotJSON = Data()
                }
            } catch {
                print("Failed to encode profile snapshot: \(error)")
                profileSnapshotJSON = Data()
            }
        }
    }

    // MARK: - Initialization

    init(dailyPlans: [DayPlanItem], profileSnapshot: OnboardingProfileSnapshot, weekStartDate: Date) {
        self.id = UUID()
        self.generatedAt = Date()
        self.schemaVersion = 1
        self.version = 1
        self.completedSessionsThisWeek = 0
        self.progressionApplied = false
        self.weekStartDate = weekStartDate

        do {
            self.dailyPlansJSON = try JSONEncoder().encode(dailyPlans)
            self.profileSnapshotJSON = try JSONEncoder().encode(profileSnapshot)
        } catch {
            self.dailyPlansJSON = Data()
            self.profileSnapshotJSON = Data()
        }
    }

    // MARK: - Methods

    /// Get plan for a specific day (0-6, where 0 is day 1)
    func plan(for dayIndex: Int) -> DayPlanItem? {
        guard dayIndex >= 0 && dayIndex < dailyPlans.count else { return nil }
        return dailyPlans[dayIndex]
    }

    /// Get plan for today
    func todaysPlan() -> DayPlanItem? {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: weekStartDate, to: Date()).day ?? 0
        return plan(for: daysSinceStart)
    }

    /// Mark a session as completed
    func markSessionCompleted(dayIndex: Int, sessionId: UUID) {
        var plans = dailyPlans
        guard dayIndex >= 0 && dayIndex < plans.count else { return }

        var day = plans[dayIndex]
        day.markSessionCompleted(sessionId: sessionId)
        plans[dayIndex] = day
        dailyPlans = plans

        completedSessionsThisWeek += 1
    }

    /// Check if progression should be applied (5+ sessions completed this week)
    var shouldApplyProgression: Bool {
        completedSessionsThisWeek >= 5 && !progressionApplied
    }

    /// Total duration for the week
    var totalWeekDurationSeconds: Int {
        dailyPlans.reduce(0) { $0 + $1.totalDurationSeconds }
    }

    /// Average daily duration
    var averageDailyDurationSeconds: Int {
        guard !dailyPlans.isEmpty else { return 0 }
        return totalWeekDurationSeconds / dailyPlans.count
    }
}

// MARK: - Day Plan Item (one day's worth of sessions)

struct DayPlanItem: Codable, Identifiable, Hashable {
    var id: UUID
    var dayIndex: Int  // 0-6 (Day 1 to Day 7)
    var sessions: [MicroSession]
    var focusLabel: String  // e.g., "Neck & Shoulders"
    var theme: String  // e.g., "Foundation", "Build Strength", "Recovery"

    init(dayIndex: Int, sessions: [MicroSession], focusLabel: String, theme: String) {
        self.id = UUID()
        self.dayIndex = dayIndex
        self.sessions = sessions
        self.focusLabel = focusLabel
        self.theme = theme
    }

    var totalDurationSeconds: Int {
        sessions.reduce(0) { $0 + $1.durationSeconds }
    }

    var totalDurationMinutes: Int {
        (totalDurationSeconds + 30) / 60  // Round to nearest minute
    }

    var completedSessionCount: Int {
        sessions.filter { $0.isCompleted }.count
    }

    var isFullyCompleted: Bool {
        sessions.allSatisfy { $0.isCompleted }
    }

    mutating func markSessionCompleted(sessionId: UUID) {
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            sessions[index].isCompleted = true
            sessions[index].completedAt = Date()
        }
    }
}

// MARK: - Micro Session (individual session within a day)

struct MicroSession: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String  // e.g., "Morning Reset", "Midday Desk Break"
    var sessionType: SessionType
    var exerciseIds: [String]
    var durationSeconds: Int
    var isCompleted: Bool
    var completedAt: Date?

    init(
        title: String,
        sessionType: SessionType,
        exerciseIds: [String],
        durationSeconds: Int
    ) {
        self.id = UUID()
        self.title = title
        self.sessionType = sessionType
        self.exerciseIds = exerciseIds
        self.durationSeconds = durationSeconds
        self.isCompleted = false
        self.completedAt = nil
    }

    var durationMinutes: Int {
        (durationSeconds + 30) / 60
    }

    var displayDuration: String {
        "\(durationMinutes) min"
    }
}

// MARK: - Onboarding Profile Snapshot (for plan regeneration and display)

struct OnboardingProfileSnapshot: Codable, Hashable {
    let goal: String
    let focusAreas: [String]
    let painAreas: [String]
    let postureIssues: [String]
    let stiffnessTimes: [String]
    let workType: String?
    let sedentaryHoursBucket: String?
    let exerciseFrequency: String?
    let motivationLevel: String?
    let dailyTimeMinutes: Int
    let workStartMinutes: Int
    let workEndMinutes: Int

    // MARK: - Computed Properties for Display

    var goalEnum: UserGoal? {
        UserGoal(rawValue: goal)
    }

    var focusAreasEnum: Set<FocusArea> {
        Set(focusAreas.compactMap { FocusArea(rawValue: $0) })
    }

    var painAreasEnum: Set<PainArea> {
        Set(painAreas.compactMap { PainArea(rawValue: $0) })
    }

    var postureIssuesEnum: Set<PostureIssue> {
        Set(postureIssues.compactMap { PostureIssue(rawValue: $0) })
    }

    var stiffnessTimesEnum: Set<StiffnessTime> {
        Set(stiffnessTimes.compactMap { StiffnessTime(rawValue: $0) })
    }

    var workTypeEnum: WorkType? {
        guard let wt = workType else { return nil }
        return WorkType(rawValue: wt)
    }

    var exerciseFrequencyEnum: ExerciseFrequency? {
        guard let ef = exerciseFrequency else { return nil }
        return ExerciseFrequency(rawValue: ef)
    }

    var motivationLevelEnum: MotivationLevel? {
        guard let ml = motivationLevel else { return nil }
        return MotivationLevel(rawValue: ml)
    }

    // MARK: - Display Helpers

    /// Primary descriptor for the plan (e.g., "Desk work • Morning stiffness • Neck + Upper Back")
    var planDescriptor: String {
        var parts: [String] = []

        // Work type
        if let wt = workTypeEnum {
            switch wt {
            case .deskOffice, .deskHome: parts.append("Desk work")
            case .hybrid: parts.append("Hybrid work")
            case .standing: parts.append("Standing desk")
            case .mixed: parts.append("Active work")
            }
        }

        // Stiffness times
        if stiffnessTimesEnum.count == 1, let time = stiffnessTimesEnum.first {
            parts.append("\(time.displayName) stiffness")
        } else if !stiffnessTimesEnum.isEmpty {
            parts.append("All-day stiffness")
        }

        // Focus areas (top 2)
        let focusNames = focusAreasEnum.prefix(2).map { $0.displayName }
        if !focusNames.isEmpty {
            parts.append(focusNames.joined(separator: " + "))
        }

        return parts.joined(separator: " • ")
    }

    /// Number of sessions per day based on available time
    var sessionsPerDay: Int {
        switch dailyTimeMinutes {
        case 0...4: return 1
        case 5...8: return 2
        default: return 3
        }
    }

    /// Create from UserProfile
    static func from(profile: UserProfile) -> OnboardingProfileSnapshot {
        OnboardingProfileSnapshot(
            goal: profile.goal,
            focusAreas: profile.focusAreas,
            painAreas: profile.painAreas,
            postureIssues: profile.postureIssues,
            stiffnessTimes: profile.stiffnessTimes,
            workType: profile.workType,
            sedentaryHoursBucket: profile.sedentaryHoursBucket,
            exerciseFrequency: profile.exerciseFrequency,
            motivationLevel: profile.motivationLevel,
            dailyTimeMinutes: profile.dailyTimeMinutes,
            workStartMinutes: profile.workStartMinutes,
            workEndMinutes: profile.workEndMinutes
        )
    }
}

// MARK: - Plan Generation Result

struct PlanGenerationResult {
    let plan: WeeklyPlan
    let whyThisFits: [String]  // 3 bullet points explaining personalization
    let progressionPromise: String  // Safe, motivational phrasing
}
