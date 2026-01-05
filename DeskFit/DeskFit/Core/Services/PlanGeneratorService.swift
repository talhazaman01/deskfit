import Foundation
import SwiftData

class PlanGeneratorService {
    static let shared = PlanGeneratorService()

    private let exerciseService = ExerciseService.shared

    private init() {}

    func generateDailyPlan(for profile: UserProfile) -> DailyPlan {
        let sessionDuration = calculateSessionDuration(dailyMinutes: profile.dailyTimeMinutes)
        let focusAreas = profile.focusAreas.isEmpty ? FocusArea.allCases.map { $0.rawValue } : profile.focusAreas
        let stiffnessTimes = profile.stiffnessTimesEnum

        // Generate sessions with tailored titles based on stiffness times
        let sessions = [
            generateSession(
                type: .morning,
                duration: sessionDuration,
                focusAreas: focusAreas,
                stiffnessTimes: stiffnessTimes
            ),
            generateSession(
                type: .midday,
                duration: sessionDuration,
                focusAreas: focusAreas,
                stiffnessTimes: stiffnessTimes
            ),
            generateSession(
                type: .afternoon,
                duration: sessionDuration,
                focusAreas: focusAreas,
                stiffnessTimes: stiffnessTimes
            )
        ]

        return DailyPlan(date: Date(), sessions: sessions)
    }

    private func generateSession(
        type: SessionType,
        duration: Int,
        focusAreas: [String],
        stiffnessTimes: Set<StiffnessTime>
    ) -> PlannedSession {
        let exercises = exerciseService.getExercises(forDuration: duration, focusAreas: focusAreas)
        let totalDuration = exercises.reduce(0) { $0 + $1.durationSeconds }

        // Create base session
        var session = PlannedSession(
            type: type,
            exerciseIds: exercises.map { $0.id },
            durationSeconds: totalDuration
        )

        // Customize title based on stiffness time preferences
        session = customizeSessionTitle(session: session, stiffnessTimes: stiffnessTimes)

        return session
    }

    /// Customize session title based on when user typically feels stiff
    private func customizeSessionTitle(session: PlannedSession, stiffnessTimes: Set<StiffnessTime>) -> PlannedSession {
        guard !stiffnessTimes.isEmpty else {
            return session
        }

        var modifiedSession = session

        // If this session matches one of the user's stiffness times, add personalized messaging
        switch session.type {
        case .morning where stiffnessTimes.contains(.morning):
            modifiedSession.title = "Morning Relief"
        case .midday where stiffnessTimes.contains(.midday):
            modifiedSession.title = "Midday Unwind"
        case .afternoon where stiffnessTimes.contains(.evening):
            modifiedSession.title = "Evening Reset"
        default:
            // Keep default titles for non-matching times
            break
        }

        return modifiedSession
    }

    private func calculateSessionDuration(dailyMinutes: Int) -> Int {
        (dailyMinutes * 60) / 3
    }

    func getTodaysPlan(context: ModelContext, profile: UserProfile) -> DailyPlan {
        let today = Calendar.current.startOfDay(for: Date())

        let descriptor = FetchDescriptor<DailyPlan>(
            predicate: #Predicate { $0.date == today }
        )

        if let existingPlan = try? context.fetch(descriptor).first {
            return existingPlan
        }

        let newPlan = generateDailyPlan(for: profile)
        context.insert(newPlan)
        try? context.save()
        return newPlan
    }

    func markSessionCompleted(session: PlannedSession, in plan: DailyPlan, context: ModelContext) {
        plan.markSessionCompleted(sessionId: session.id)
        try? context.save()
    }

    /// Mark a session as completed in the weekly plan
    func markSessionCompletedInWeeklyPlan(session: PlannedSession, in weeklyPlan: WeeklyPlan, context: ModelContext) {
        let calendar = Calendar.current
        let dayIndex = calendar.dateComponents([.day], from: weeklyPlan.weekStartDate, to: Date()).day ?? 0
        let clampedDayIndex = min(6, max(0, dayIndex))
        weeklyPlan.markSessionCompleted(dayIndex: clampedDayIndex, sessionId: session.id)
        try? context.save()
    }

    // MARK: - Starter Reset Generation

    /// Generate a tailored starter reset based on user's stiffness times and focus areas
    func generateStarterReset(
        focusAreas: Set<FocusArea>,
        stiffnessTimes: Set<StiffnessTime>,
        targetDuration: Int = 60
    ) -> (title: String, exercises: [Exercise]) {
        let focusAreaStrings = focusAreas.map { $0.rawValue }
        let exercises = exerciseService.getExercises(forDuration: targetDuration, focusAreas: focusAreaStrings)

        // Customize starter reset title based on stiffness times
        let title: String
        if stiffnessTimes.isEmpty {
            title = "Your First Reset"
        } else if stiffnessTimes.count == StiffnessTime.allCases.count {
            // All day selected
            title = "Your Daily Reset"
        } else if stiffnessTimes.count == 1, let singleTime = stiffnessTimes.first {
            // Single time selected - use specific title
            switch singleTime {
            case .morning:
                title = "Morning Wake-Up"
            case .midday:
                title = "Quick Desk Reset"
            case .evening:
                title = "End-of-Day Unwind"
            }
        } else {
            // Multiple (but not all) times selected
            title = "Your First Reset"
        }

        return (title, exercises)
    }
}

// MARK: - Weekly Plan Generation

extension PlanGeneratorService {

    /// Generate a personalized 7-day weekly plan based on user profile
    func generateWeeklyPlan(for profile: UserProfile) -> PlanGenerationResult {
        let snapshot = OnboardingProfileSnapshot.from(profile: profile)
        let weekStartDate = Self.currentWeekStartDate()

        let dailyPlans = generateDailyPlansForWeek(profile: profile, snapshot: snapshot)
        let whyThisFits = generateWhyThisFits(profile: profile, snapshot: snapshot)
        let progressionPromise = generateProgressionPromise(profile: profile)

        let plan = WeeklyPlan(
            dailyPlans: dailyPlans,
            profileSnapshot: snapshot,
            weekStartDate: weekStartDate
        )

        return PlanGenerationResult(
            plan: plan,
            whyThisFits: whyThisFits,
            progressionPromise: progressionPromise
        )
    }

    /// Get or create this week's plan
    func getOrCreateWeeklyPlan(context: ModelContext, profile: UserProfile) -> WeeklyPlan {
        let weekStart = Self.currentWeekStartDate()

        let descriptor = FetchDescriptor<WeeklyPlan>(
            predicate: #Predicate { $0.weekStartDate == weekStart }
        )

        if let existingPlan = try? context.fetch(descriptor).first {
            return existingPlan
        }

        let result = generateWeeklyPlan(for: profile)
        context.insert(result.plan)
        try? context.save()
        return result.plan
    }

    // MARK: - Daily Plans Generation

    private func generateDailyPlansForWeek(
        profile: UserProfile,
        snapshot: OnboardingProfileSnapshot
    ) -> [DayPlanItem] {
        let themes = weekThemes(for: profile)
        let focusRotation = focusAreaRotation(for: profile)

        return (0..<7).map { dayIndex in
            let theme = themes[dayIndex % themes.count]
            let dayFocusAreas = focusRotation[dayIndex % focusRotation.count]
            let focusLabel = dayFocusAreas.map { $0.displayName }.joined(separator: " & ")

            let sessions = generateSessionsForDay(
                dayIndex: dayIndex,
                focusAreas: dayFocusAreas,
                theme: theme,
                profile: profile,
                snapshot: snapshot
            )

            return DayPlanItem(
                dayIndex: dayIndex,
                sessions: sessions,
                focusLabel: focusLabel,
                theme: theme.displayName
            )
        }
    }

    private func generateSessionsForDay(
        dayIndex: Int,
        focusAreas: [FocusArea],
        theme: DayTheme,
        profile: UserProfile,
        snapshot: OnboardingProfileSnapshot
    ) -> [MicroSession] {
        let sessionsPerDay = snapshot.sessionsPerDay
        let sessionDuration = (profile.dailyTimeMinutes * 60) / max(sessionsPerDay, 1)

        let sessionTypes: [SessionType] = {
            switch sessionsPerDay {
            case 1:
                // Single session - pick based on primary stiffness time
                if let primaryStiffness = snapshot.stiffnessTimesEnum.first {
                    return [primaryStiffness.preferredFirstSession]
                }
                return [.midday]
            case 2:
                return [.morning, .afternoon]
            default:
                return [.morning, .midday, .afternoon]
            }
        }()

        return sessionTypes.prefix(sessionsPerDay).enumerated().map { index, sessionType in
            let exercises = selectExercisesForSession(
                sessionType: sessionType,
                focusAreas: focusAreas,
                theme: theme,
                targetDuration: sessionDuration,
                profile: profile
            )

            let title = sessionTitle(
                for: sessionType,
                theme: theme,
                stiffnessTimes: snapshot.stiffnessTimesEnum
            )

            let totalDuration = exercises.reduce(0) { $0 + $1.durationSeconds }

            return MicroSession(
                title: title,
                sessionType: sessionType,
                exerciseIds: exercises.map { $0.id },
                durationSeconds: totalDuration
            )
        }
    }

    // MARK: - Exercise Selection with Relevance Scoring

    private func selectExercisesForSession(
        sessionType: SessionType,
        focusAreas: [FocusArea],
        theme: DayTheme,
        targetDuration: Int,
        profile: UserProfile
    ) -> [Exercise] {
        let allExercises = exerciseService.getAllExercises()

        // Score and sort exercises by relevance
        let scoredExercises = allExercises.map { exercise -> (Exercise, Int) in
            var score = exercise.relevanceScore(
                forFocusAreas: Set(focusAreas),
                painAreas: profile.painAreasEnum,
                postureIssues: profile.postureIssuesEnum,
                stiffnessTimes: profile.stiffnessTimesEnum
            )

            // Boost score for matching context
            if exercise.contextTagsEnum.contains(sessionType.contextTag) {
                score += 3
            }

            // Boost score for matching theme intent
            let themeIntents = theme.preferredIntents
            let intentMatch = Set(exercise.intentTagsEnum).intersection(themeIntents).count
            score += intentMatch * 2

            // Difficulty matching based on exercise frequency
            let targetDifficulty = profile.exerciseFrequencyEnum?.suggestedDifficulty ?? .easy
            if exercise.difficultyEnum == targetDifficulty {
                score += 2
            } else if exercise.difficultyEnum.sortOrder < targetDifficulty.sortOrder {
                score += 1 // Slightly prefer easier if not exact match
            }

            return (exercise, score)
        }
        .sorted { $0.1 > $1.1 }

        // Select exercises to fill target duration
        var selectedExercises: [Exercise] = []
        var currentDuration = 0
        var usedFocusAreas: Set<FocusArea> = []

        for (exercise, _) in scoredExercises {
            if currentDuration >= targetDuration {
                break
            }

            // Ensure variety - don't pick too many exercises for same focus area
            let exerciseFocusAreas = Set(exercise.focusAreasEnum)
            let overlapCount = exerciseFocusAreas.intersection(usedFocusAreas).count

            // Allow up to 2 exercises per focus area per session
            if overlapCount < 2 || selectedExercises.count < 2 {
                selectedExercises.append(exercise)
                currentDuration += exercise.durationSeconds
                usedFocusAreas.formUnion(exerciseFocusAreas)
            }
        }

        return selectedExercises
    }

    // MARK: - Themes and Focus Rotation

    private func weekThemes(for profile: UserProfile) -> [DayTheme] {
        // Customize theme order based on user's goal and motivation
        let baseThemes: [DayTheme]

        switch profile.motivationLevelEnum {
        case .curious:
            // Gentler progression for curious users
            baseThemes = [.foundation, .mobility, .foundation, .recovery, .mobility, .foundation, .recovery]
        case .veryMotivated:
            // More challenging for motivated users
            baseThemes = [.foundation, .buildStrength, .mobility, .buildStrength, .activeRecovery, .buildStrength, .recovery]
        default:
            // Balanced for ready users
            baseThemes = [.foundation, .mobility, .buildStrength, .recovery, .foundation, .mobility, .activeRecovery]
        }

        return baseThemes
    }

    private func focusAreaRotation(for profile: UserProfile) -> [[FocusArea]] {
        // Get user's priority focus areas (from pain areas and explicit focus)
        var priorityAreas: [FocusArea] = []

        // Add focus areas from pain areas (highest priority)
        for painArea in profile.painAreasEnum {
            priorityAreas.append(contentsOf: painArea.relatedFocusAreas)
        }

        // Add focus areas from posture issues
        for postureIssue in profile.postureIssuesEnum {
            priorityAreas.append(contentsOf: postureIssue.relatedFocusAreas)
        }

        // Add explicitly selected focus areas
        let selectedFocusAreas = profile.focusAreas.compactMap { FocusArea(rawValue: $0) }
        priorityAreas.append(contentsOf: selectedFocusAreas)

        // Remove duplicates while preserving priority order
        var seen: Set<FocusArea> = []
        let uniquePriority = priorityAreas.filter { seen.insert($0).inserted }

        // If user hasn't selected anything, use all focus areas
        let effectiveFocusAreas = uniquePriority.isEmpty ? Array(FocusArea.allCases) : uniquePriority

        // Create 7-day rotation with pairs of focus areas
        var rotation: [[FocusArea]] = []
        for i in 0..<7 {
            let primary = effectiveFocusAreas[i % effectiveFocusAreas.count]
            let secondary = effectiveFocusAreas[(i + 1) % effectiveFocusAreas.count]

            if primary == secondary {
                rotation.append([primary])
            } else {
                rotation.append([primary, secondary])
            }
        }

        return rotation
    }

    // MARK: - Session Titles

    private func sessionTitle(
        for sessionType: SessionType,
        theme: DayTheme,
        stiffnessTimes: Set<StiffnessTime>
    ) -> String {
        // Check if this session time matches user's stiffness time
        let matchesStiffness: Bool = {
            switch sessionType {
            case .morning: return stiffnessTimes.contains(.morning)
            case .midday: return stiffnessTimes.contains(.midday)
            case .afternoon: return stiffnessTimes.contains(.evening)
            }
        }()

        if matchesStiffness {
            // Personalized titles for stiffness-matching sessions
            switch sessionType {
            case .morning: return "Morning Relief"
            case .midday: return "Midday Unwind"
            case .afternoon: return "Evening Reset"
            }
        }

        // Theme-based titles
        switch (theme, sessionType) {
        case (.recovery, _): return "Gentle Recovery"
        case (.activeRecovery, _): return "Light Movement"
        case (.buildStrength, .morning): return "Morning Activation"
        case (.buildStrength, _): return "Desk Strengthener"
        case (.mobility, .morning): return "Wake-Up Flow"
        case (.mobility, _): return "Mobility Break"
        case (.foundation, .morning): return "Morning Reset"
        case (.foundation, .midday): return "Midday Refresh"
        case (.foundation, .afternoon): return "Afternoon Stretch"
        }
    }

    // MARK: - Personalization Bullets

    private func generateWhyThisFits(
        profile: UserProfile,
        snapshot: OnboardingProfileSnapshot
    ) -> [String] {
        var bullets: [String] = []

        // Bullet 1: Based on pain/focus areas
        if !profile.painAreasEnum.isEmpty {
            let topPainAreas = profile.painAreasEnum.prefix(2).map { $0.displayName }
            bullets.append("Targets your \(topPainAreas.joined(separator: " and ").lowercased()) with specific relief exercises")
        } else if !profile.focusAreas.isEmpty {
            let topFocus = profile.focusAreas.prefix(2).compactMap { FocusArea(rawValue: $0)?.displayName }
            bullets.append("Focuses on your \(topFocus.joined(separator: " and ").lowercased()) as requested")
        }

        // Bullet 2: Based on schedule/time
        let sessionsPerDay = snapshot.sessionsPerDay
        let sessionWord = sessionsPerDay == 1 ? "session" : "sessions"
        bullets.append("\(sessionsPerDay) quick \(sessionWord) per day that fit your \(profile.dailyTimeMinutes)-minute window")

        // Bullet 3: Based on stiffness times
        if !snapshot.stiffnessTimesEnum.isEmpty {
            if snapshot.stiffnessTimesEnum.count == StiffnessTime.allCases.count {
                bullets.append("Spread throughout your day to combat all-day stiffness")
            } else {
                let times = snapshot.stiffnessTimesEnum.map { $0.displayName.lowercased() }
                bullets.append("Timed for when you feel stiffest: \(times.joined(separator: " and "))")
            }
        }

        // Ensure we have exactly 3 bullets
        if bullets.count < 3 {
            if let workType = profile.workTypeEnum {
                switch workType {
                case .deskOffice, .deskHome:
                    bullets.append("Designed for desk workers with exercises you can do at your workspace")
                case .hybrid:
                    bullets.append("Flexible exercises that work whether you're at home or the office")
                case .standing:
                    bullets.append("Includes movements to complement your standing desk routine")
                case .mixed:
                    bullets.append("Balanced mix of seated and standing exercises for your varied workday")
                }
            }
        }

        return Array(bullets.prefix(3))
    }

    private func generateProgressionPromise(profile: UserProfile) -> String {
        switch profile.motivationLevelEnum {
        case .curious:
            return "We'll keep it light and build up gradually as you get comfortable."
        case .veryMotivated:
            return "Complete 5 sessions this week to unlock more challenging exercises."
        default:
            return "Stick with it for a week and you'll start feeling the difference."
        }
    }

    // MARK: - Helpers

    static func currentWeekStartDate() -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        // Calculate days since Monday (weekday 2 in Gregorian calendar)
        let daysSinceMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysSinceMonday, to: today) ?? today
    }
}

// MARK: - Day Theme

enum DayTheme: String, CaseIterable {
    case foundation
    case mobility
    case buildStrength
    case recovery
    case activeRecovery

    var displayName: String {
        switch self {
        case .foundation: return "Foundation"
        case .mobility: return "Mobility"
        case .buildStrength: return "Build Strength"
        case .recovery: return "Recovery"
        case .activeRecovery: return "Active Recovery"
        }
    }

    var preferredIntents: Set<ExerciseIntentTag> {
        switch self {
        case .foundation:
            return [.mobility, .stretching, .activation]
        case .mobility:
            return [.mobility, .decompression]
        case .buildStrength:
            return [.strengthening, .activation]
        case .recovery:
            return [.stretching, .breathing, .decompression]
        case .activeRecovery:
            return [.mobility, .breathing, .stretching]
        }
    }
}

// MARK: - SessionType Extension

extension SessionType {
    var contextTag: ExerciseContextTag {
        switch self {
        case .morning: return .morning
        case .midday: return .midday
        case .afternoon: return .evening
        }
    }
}

// MARK: - PlannedSession Extension for Title Modification

extension PlannedSession {
    /// Create a copy with modified title
    mutating func updateTitle(_ newTitle: String) {
        self.title = newTitle
    }
}
