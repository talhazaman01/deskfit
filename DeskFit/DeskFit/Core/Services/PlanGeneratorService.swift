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

// MARK: - PlannedSession Extension for Title Modification

extension PlannedSession {
    /// Create a copy with modified title
    mutating func updateTitle(_ newTitle: String) {
        self.title = newTitle
    }
}
