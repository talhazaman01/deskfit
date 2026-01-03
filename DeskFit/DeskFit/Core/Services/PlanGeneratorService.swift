import Foundation
import SwiftData

class PlanGeneratorService {
    static let shared = PlanGeneratorService()

    private let exerciseService = ExerciseService.shared

    private init() {}

    func generateDailyPlan(for profile: UserProfile) -> DailyPlan {
        let sessionDuration = calculateSessionDuration(dailyMinutes: profile.dailyTimeMinutes)
        let focusAreas = profile.focusAreas.isEmpty ? FocusArea.allCases.map { $0.rawValue } : profile.focusAreas

        let sessions = [
            generateSession(type: .morning, duration: sessionDuration, focusAreas: focusAreas),
            generateSession(type: .midday, duration: sessionDuration, focusAreas: focusAreas),
            generateSession(type: .afternoon, duration: sessionDuration, focusAreas: focusAreas)
        ]

        return DailyPlan(date: Date(), sessions: sessions)
    }

    private func generateSession(type: SessionType, duration: Int, focusAreas: [String]) -> PlannedSession {
        let exercises = exerciseService.getExercises(forDuration: duration, focusAreas: focusAreas)
        let totalDuration = exercises.reduce(0) { $0 + $1.durationSeconds }

        return PlannedSession(
            type: type,
            exerciseIds: exercises.map { $0.id },
            durationSeconds: totalDuration
        )
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
}
