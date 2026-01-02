import Foundation
import SwiftData

@MainActor
class UserProfileManager {
    static let shared = UserProfileManager()

    private init() {}

    func getOrCreateProfile(context: ModelContext) -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let profile = UserProfile()
        context.insert(profile)
        try? context.save()
        return profile
    }

    func updateProfile(_ profile: UserProfile, context: ModelContext) {
        try? context.save()
    }

    func recordSessionComplete(
        profile: UserProfile,
        session: PlannedSession,
        feedback: String?,
        context: ModelContext
    ) {
        let exercises = ExerciseService.shared.getExercises(ids: session.exerciseIds)
        let record = SessionRecord(
            sessionType: session.type.rawValue,
            durationSeconds: session.durationSeconds,
            exerciseIds: session.exerciseIds,
            focusAreas: exercises.flatMap { $0.focusAreas },
            feedback: feedback
        )
        context.insert(record)

        profile.totalSessions += 1
        profile.totalMinutes += session.durationSeconds / 60

        StreakService.shared.updateStreak(for: profile, context: context)

        try? context.save()
    }
}
