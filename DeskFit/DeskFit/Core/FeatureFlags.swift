import Foundation

// MARK: - Feature Flags
// =====================================
// Centralized feature flag system for DeskFit.
// Flags can be derived from user state, remote config, or compile-time constants.
//
// PATTERN:
// - Static computed properties for runtime checks
// - Source of truth varies by feature (user preferences, A/B tests, etc.)
//
// AIRPODS POSTURE NUDGES:
// - Enabled when user self-reported "Yes, I have AirPods" in onboarding
// - Detection is NOT sufficient - user must explicitly opt-in
// - Unknown/nil state defaults to disabled
// =====================================

/// Centralized feature flags for the app.
/// Access flags via `FeatureFlags.flagName`.
@MainActor
enum FeatureFlags {

    // MARK: - AirPods Features

    /// Whether AirPods Posture Nudges feature is enabled.
    /// This gates access to posture tracking and gentle reminders via AirPods.
    ///
    /// Source of truth: `AirPodsCapabilityStore.selfReportedResponse`
    /// - Returns `true` only if user explicitly selected "Yes, I have AirPods"
    /// - Returns `false` for "No", "Not sure", or unanswered
    static var airpodsPostureNudges: Bool {
        AirPodsCapabilityStore.shared.airpodsSelfReported == true
    }

    /// Whether the user has completed the AirPods onboarding question.
    /// Use this to determine if we should prompt them later.
    static var hasAnsweredAirPodsQuestion: Bool {
        AirPodsCapabilityStore.shared.hasAnsweredOnboarding
    }

    /// Whether we should show the AirPods upsell card.
    /// Shows when user has answered but doesn't have AirPods enabled.
    static var shouldShowAirPodsUpsell: Bool {
        hasAnsweredAirPodsQuestion && !airpodsPostureNudges
    }

    /// Whether headphones are currently detected (hint only, not for gating).
    /// Use this for UI hints like "We detected headphones connected".
    static var isHeadphoneCurrentlyDetected: Bool {
        AirPodsDetectionService.shared.isHeadphoneDetected
    }

    // MARK: - Example: How to Add New Flags
    //
    // static var newFeatureName: Bool {
    //     // Return true/false based on user state, remote config, etc.
    //     UserDefaults.standard.bool(forKey: "feature_new_feature_name")
    // }
}

// MARK: - Feature Flag Convenience Extensions

extension FeatureFlags {
    /// Debug description of all current flag states.
    /// Useful for debugging and analytics.
    static var debugDescription: String {
        """
        Feature Flags:
        - airpodsPostureNudges: \(airpodsPostureNudges)
        - hasAnsweredAirPodsQuestion: \(hasAnsweredAirPodsQuestion)
        - shouldShowAirPodsUpsell: \(shouldShowAirPodsUpsell)
        - isHeadphoneCurrentlyDetected: \(isHeadphoneCurrentlyDetected)
        """
    }
}
