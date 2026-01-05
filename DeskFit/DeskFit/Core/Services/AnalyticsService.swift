import Foundation

/// Stub analytics service - prints to console in DEBUG.
/// Replace with real provider (Mixpanel, Amplitude, PostHog) before launch.
/// Marked Sendable with nonisolated static shared for cross-actor access in Swift 6.
final class AnalyticsService: Sendable {
    /// Nonisolated to allow access from any actor (e.g., NotificationService).
    nonisolated static let shared = AnalyticsService()

    private init() {}

    enum Event {
        case appOpened(isFirstLaunch: Bool)

        case onboardingStarted
        case onboardingStepCompleted(step: String)
        case onboardingPersonalInfo(step: String, ageBand: String?, gender: String?, hasHeight: Bool?, hasWeight: Bool?)
        case onboardingStiffnessTime(stiffnessTime: String)
        case onboardingWorkHours(sedentaryHoursBucket: String?)
        case onboardingCompleted(durationSeconds: Int, goal: String, focusAreas: [String], dailyMinutes: Int, stiffnessTime: String?)
        case onboardingSummaryViewed
        case onboardingSafetyAcknowledged(action: String)
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

        // AirPods Detection
        case onboardingAirpodsQuestionViewed
        case onboardingAirpodsAnswered(value: String, detectedNow: Bool)
        case airpodsRouteDetected(detected: Bool, routeType: String)
        case airpodsPostureNudgesEnabled
        case airpodsUpsellViewed(source: String)
        case airpodsUpsellTapped(action: String)

        // Analysis Report
        case analysisViewed(score: Int, category: String, insightCount: Int)
        case analysisCtaTapped
        case analysisInsightRendered(tags: [String])

        // Tab Navigation
        case tabOpened(name: String)

        // Session Actions (with source tracking)
        case sessionStartedFromSource(sessionId: String, source: String)

        // Progress
        case progressViewed
        case progressDayOpened(dayIndex: Int, date: String)

        // Upgrade Prompts
        case upgradeCardViewed(source: String)
        case upgradeTapped(source: String)

        // Training
        case planDayOpened(dayIndex: Int)
        case libraryOpened
        case exerciseViewed(exerciseId: String, source: String)
        case quickResetStarted(source: String)
    }

    nonisolated func track(_ event: Event) {
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

    private nonisolated func eventDetails(_ event: Event) -> (name: String, properties: [String: Any]) {
        switch event {
        case .appOpened(let isFirstLaunch):
            return ("app_opened", ["is_first_launch": isFirstLaunch])

        case .onboardingStarted:
            return ("onboarding_started", [:])

        case .onboardingStepCompleted(let step):
            return ("onboarding_step_completed", ["step": step])

        case .onboardingPersonalInfo(let step, let ageBand, let gender, let hasHeight, let hasWeight):
            var props: [String: Any] = ["step": step]
            if let ageBand = ageBand { props["age_band"] = ageBand }
            if let gender = gender { props["gender"] = gender }
            if let hasHeight = hasHeight { props["has_height"] = hasHeight }
            if let hasWeight = hasWeight { props["has_weight"] = hasWeight }
            return ("onboarding_personal_info", props)

        case .onboardingStiffnessTime(let stiffnessTime):
            // stiffnessTime is either "all_day" or comma-separated values like "morning,evening"
            let value: Any = stiffnessTime == "all_day"
                ? stiffnessTime
                : stiffnessTime.split(separator: ",").map(String.init)
            return ("onboarding_stiffness_time", ["stiffness_time": value])

        case .onboardingWorkHours(let sedentaryHoursBucket):
            var props: [String: Any] = ["step": "work_hours"]
            if let bucket = sedentaryHoursBucket {
                props["sedentary_hours_bucket"] = bucket
            }
            return ("onboarding_step_completed", props)

        case .onboardingCompleted(let duration, let goal, let focusAreas, let dailyMinutes, let stiffnessTime):
            var props: [String: Any] = [
                "duration_seconds": duration,
                "goal": goal,
                "focus_areas": focusAreas,
                "daily_minutes": dailyMinutes
            ]
            if let stiffnessTime = stiffnessTime, !stiffnessTime.isEmpty {
                // stiffnessTime is either "all_day" or comma-separated values like "morning,evening"
                let value: Any = stiffnessTime == "all_day"
                    ? stiffnessTime
                    : stiffnessTime.split(separator: ",").map(String.init)
                props["stiffness_time"] = value
            }
            return ("onboarding_completed", props)

        case .onboardingSummaryViewed:
            return ("onboarding_summary_viewed", [:])

        case .onboardingSafetyAcknowledged(let action):
            return ("onboarding_safety_acknowledged", ["action": action])

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

        case .onboardingAirpodsQuestionViewed:
            return ("onboarding_airpods_question_viewed", [:])

        case .onboardingAirpodsAnswered(let value, let detectedNow):
            return ("onboarding_airpods_answered", [
                "value": value,
                "detected_now": detectedNow
            ])

        case .airpodsRouteDetected(let detected, let routeType):
            return ("airpods_route_detected", [
                "detected": detected,
                "route_type": routeType
            ])

        case .airpodsPostureNudgesEnabled:
            return ("airpods_posture_nudges_enabled", [:])

        case .airpodsUpsellViewed(let source):
            return ("airpods_upsell_viewed", ["source": source])

        case .airpodsUpsellTapped(let action):
            return ("airpods_upsell_tapped", ["action": action])

        case .analysisViewed(let score, let category, let insightCount):
            return ("analysis_viewed", [
                "score": score,
                "category": category,
                "insight_count": insightCount
            ])

        case .analysisCtaTapped:
            return ("analysis_cta_tapped", [:])

        case .analysisInsightRendered(let tags):
            return ("analysis_insight_rendered", ["tags": tags])

        case .tabOpened(let name):
            return ("tab_opened", ["name": name])

        case .sessionStartedFromSource(let sessionId, let source):
            return ("session_started_from_source", [
                "session_id": sessionId,
                "source": source
            ])

        case .progressViewed:
            return ("progress_viewed", [:])

        case .progressDayOpened(let dayIndex, let date):
            return ("progress_day_opened", [
                "day_index": dayIndex,
                "date": date
            ])

        case .upgradeCardViewed(let source):
            return ("upgrade_card_viewed", ["source": source])

        case .upgradeTapped(let source):
            return ("upgrade_tapped", ["source": source])

        case .planDayOpened(let dayIndex):
            return ("plan_day_opened", ["day_index": dayIndex])

        case .libraryOpened:
            return ("library_opened", [:])

        case .exerciseViewed(let exerciseId, let source):
            return ("exercise_viewed", [
                "exercise_id": exerciseId,
                "source": source
            ])

        case .quickResetStarted(let source):
            return ("quick_reset_started", ["source": source])
        }
    }
}
