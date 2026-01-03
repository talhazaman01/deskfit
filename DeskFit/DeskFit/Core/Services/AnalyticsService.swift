import Foundation

/// Stub analytics service - prints to console in DEBUG.
/// Replace with real provider (Mixpanel, Amplitude, PostHog) before launch.
final class AnalyticsService: @unchecked Sendable {
    static let shared = AnalyticsService()

    private init() {}

    enum Event {
        case appOpened(isFirstLaunch: Bool)

        case onboardingStarted
        case onboardingStepCompleted(step: String)
        case onboardingCompleted(durationSeconds: Int, goal: String, focusAreas: [String], dailyMinutes: Int)
        case onboardingSummaryViewed
        case starterResetStarted
        case starterResetCompleted(durationSeconds: Int, exerciseCount: Int)
        case starterResetSkipped

        case sessionStarted(sessionId: String, sessionType: String, durationSeconds: Int, exerciseCount: Int)
        case sessionPaused(sessionId: String, elapsedSeconds: Int)
        case sessionResumed(sessionId: String, pauseDurationSeconds: Int)
        case sessionAbandoned(sessionId: String, completedExercises: Int, totalExercises: Int)
        case sessionCompleted(sessionId: String, durationSeconds: Int, feedback: String?)
        case exerciseCompleted(exerciseId: String, durationSeconds: Int)

        case paywallViewed(source: String)
        case paywallDismissed(source: String, selectedPlan: String?)
        case planSelected(plan: String)

        case trialStarted(plan: String, trialDays: Int)
        case subscribeSuccess(plan: String, price: Decimal, currency: String, isTrial: Bool)
        case subscribeFailed(plan: String, errorCode: String)
        case subscribeRestored(plan: String)
        case subscriptionStatusChanged(previousStatus: String, newStatus: String)

        case notificationPermissionRequested
        case notificationPermissionResult(granted: Bool)
        case reminderTapped(action: String)
        case reminderSnooze(durationMinutes: Int)

        case streakMilestone(days: Int)
        case settingsChanged(setting: String, newValue: String)
    }

    func track(_ event: Event) {
        let (name, properties) = eventDetails(event)

        // TODO: Replace with real analytics provider
        #if DEBUG
        print("📊 [Analytics] \(name)")
        if !properties.isEmpty {
            for (key, value) in properties.sorted(by: { $0.key < $1.key }) {
                print("   └─ \(key): \(value)")
            }
        }
        #endif
    }

    private func eventDetails(_ event: Event) -> (name: String, properties: [String: Any]) {
        switch event {
        case .appOpened(let isFirstLaunch):
            return ("app_opened", ["is_first_launch": isFirstLaunch])

        case .onboardingStarted:
            return ("onboarding_started", [:])

        case .onboardingStepCompleted(let step):
            return ("onboarding_step_completed", ["step": step])

        case .onboardingCompleted(let duration, let goal, let focusAreas, let dailyMinutes):
            return ("onboarding_completed", [
                "duration_seconds": duration,
                "goal": goal,
                "focus_areas": focusAreas,
                "daily_minutes": dailyMinutes
            ])

        case .onboardingSummaryViewed:
            return ("onboarding_summary_viewed", [:])

        case .starterResetStarted:
            return ("starter_reset_started", [:])

        case .starterResetCompleted(let duration, let exerciseCount):
            return ("starter_reset_completed", [
                "duration_seconds": duration,
                "exercise_count": exerciseCount
            ])

        case .starterResetSkipped:
            return ("starter_reset_skipped", [:])

        case .sessionStarted(let sessionId, let sessionType, let duration, let exerciseCount):
            return ("session_started", [
                "session_id": sessionId,
                "session_type": sessionType,
                "duration_seconds": duration,
                "exercise_count": exerciseCount
            ])

        case .sessionPaused(let sessionId, let elapsed):
            return ("session_paused", ["session_id": sessionId, "elapsed_seconds": elapsed])

        case .sessionResumed(let sessionId, let pauseDuration):
            return ("session_resumed", ["session_id": sessionId, "pause_duration_seconds": pauseDuration])

        case .sessionAbandoned(let sessionId, let completed, let total):
            return ("session_abandoned", [
                "session_id": sessionId,
                "completed_exercises": completed,
                "total_exercises": total
            ])

        case .sessionCompleted(let sessionId, let duration, let feedback):
            var props: [String: Any] = ["session_id": sessionId, "duration_seconds": duration]
            if let feedback = feedback { props["feedback"] = feedback }
            return ("session_completed", props)

        case .exerciseCompleted(let exerciseId, let duration):
            return ("exercise_completed", ["exercise_id": exerciseId, "duration_seconds": duration])

        case .paywallViewed(let source):
            return ("paywall_viewed", ["source": source])

        case .paywallDismissed(let source, let plan):
            var props: [String: Any] = ["source": source]
            if let plan = plan { props["selected_plan"] = plan }
            return ("paywall_dismissed", props)

        case .planSelected(let plan):
            return ("plan_selected", ["plan": plan])

        case .trialStarted(let plan, let trialDays):
            return ("trial_started", ["plan": plan, "trial_days": trialDays])

        case .subscribeSuccess(let plan, let price, let currency, let isTrial):
            return ("subscribe_success", [
                "plan": plan,
                "price": price,
                "currency": currency,
                "is_trial": isTrial
            ])

        case .subscribeFailed(let plan, let errorCode):
            return ("subscribe_failed", ["plan": plan, "error_code": errorCode])

        case .subscribeRestored(let plan):
            return ("subscribe_restored", ["plan": plan])

        case .subscriptionStatusChanged(let previousStatus, let newStatus):
            return ("subscription_status_changed", [
                "previous_status": previousStatus,
                "new_status": newStatus
            ])

        case .notificationPermissionRequested:
            return ("notification_permission_requested", [:])

        case .notificationPermissionResult(let granted):
            return ("notification_permission_result", ["granted": granted])

        case .reminderTapped(let action):
            return ("reminder_tapped", ["action": action])

        case .reminderSnooze(let minutes):
            return ("reminder_snooze", ["duration_minutes": minutes])

        case .streakMilestone(let days):
            return ("streak_milestone", ["days": days])

        case .settingsChanged(let setting, let newValue):
            return ("settings_changed", ["setting": setting, "new_value": newValue])
        }
    }
}
