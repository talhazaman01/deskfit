import Foundation
import SwiftData

class PlanGeneratorService {
    static let shared = PlanGeneratorService()

    private let exerciseService = ExerciseService.shared

    private init() {}

    func generateDailyPlan(for profile: UserProfile) -> DailyPlan {
        let sessionDuration = calculateSessionDuration(dailyMinutes: profile.dailyTimeMinutes)
        let focusAreas = profile.focusAreas.isEmpty ? FocusArea.allCases.map { $0.rawValue } : profile.focusAreas
        let stiffnessTime = profile.stiffnessTimeEnum

        // Generate sessions with tailored titles based on stiffness time
        let sessions = [
            generateSession(
                type: .morning,
                duration: sessionDuration,
                focusAreas: focusAreas,
                stiffnessTime: stiffnessTime
            ),
            generateSession(
                type: .midday,
                duration: sessionDuration,
                focusAreas: focusAreas,
                stiffnessTime: stiffnessTime
            ),
            generateSession(
                type: .afternoon,
                duration: sessionDuration,
                focusAreas: focusAreas,
                stiffnessTime: stiffnessTime
            )
        ]

        return DailyPlan(date: Date(), sessions: sessions)
    }

    private func generateSession(
        type: SessionType,
        duration: Int,
        focusAreas: [String],
        stiffnessTime: StiffnessTime?
    ) -> PlannedSession {
        let exercises = exerciseService.getExercises(forDuration: duration, focusAreas: focusAreas)
        let totalDuration = exercises.reduce(0) { $0 + $1.durationSeconds }

        // Create base session
        var session = PlannedSession(
            type: type,
            exerciseIds: exercises.map { $0.id },
            durationSeconds: totalDuration
        )

        // Customize title based on stiffness time preference
        session = customizeSessionTitle(session: session, stiffnessTime: stiffnessTime)

        return session
    }

    /// Customize session title based on when user typically feels stiff
    private func customizeSessionTitle(session: PlannedSession, stiffnessTime: StiffnessTime?) -> PlannedSession {
        guard let stiffnessTime = stiffnessTime else {
            return session
        }

        var modifiedSession = session

        // If this is the user's stiffness time, add personalized messaging
        switch (session.type, stiffnessTime) {
        case (.morning, .morning):
            modifiedSession.title = "Morning Relief"
        case (.midday, .midday):
            modifiedSession.title = "Midday Unwind"
        case (.afternoon, .evening):
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

    /// Generate a tailored starter reset based on user's stiffness time and focus areas
    func generateStarterReset(
        focusAreas: Set<FocusArea>,
        stiffnessTime: StiffnessTime?,
        targetDuration: Int = 60
    ) -> (title: String, exercises: [Exercise]) {
        let focusAreaStrings = focusAreas.map { $0.rawValue }
        let exercises = exerciseService.getExercises(forDuration: targetDuration, focusAreas: focusAreaStrings)

        // Customize starter reset title based on stiffness time
        let title: String
        switch stiffnessTime {
        case .morning:
            title = "Morning Wake-Up"
        case .midday:
            title = "Quick Desk Reset"
        case .evening:
            title = "End-of-Day Unwind"
        case nil:
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
