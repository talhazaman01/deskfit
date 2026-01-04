import Foundation
import Combine

// MARK: - AirPods Capability State Model

/// Represents the combined state of AirPods detection and user preference.
/// Used for feature gating decisions.
struct AirPodsCapabilityState {
    /// User's self-reported AirPods ownership (true/false/nil for unknown)
    let selfReported: Bool?

    /// Whether headphones are currently detected
    let detectedNow: Bool

    /// When the state was last updated
    let lastUpdated: Date

    /// Whether posture nudges should be enabled based on self-reported value.
    /// Returns true only if user explicitly said "Yes, I have AirPods".
    var shouldEnablePostureNudges: Bool {
        selfReported == true
    }
}

/// User's response to the AirPods onboarding question
enum AirPodsOnboardingResponse: String, Codable {
    case yes = "yes"
    case no = "no"
    case notSure = "not_sure"

    /// Convert to Bool? for feature flag logic
    var asBool: Bool? {
        switch self {
        case .yes: return true
        case .no: return false
        case .notSure: return nil
        }
    }
}

// MARK: - AirPods Capability Store

/// Manages persistence of AirPods-related user preferences and detection state.
/// Uses UserDefaults for lightweight storage (no SwiftData needed for these flags).
@MainActor
final class AirPodsCapabilityStore: ObservableObject {
    static let shared = AirPodsCapabilityStore()

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let selfReportedResponse = "airpods_self_reported_response"
        static let lastDetectedHeadphoneRoute = "airpods_last_detected_route"
        static let lastDetectionTimestamp = "airpods_last_detection_timestamp"
        static let hasAnsweredOnboarding = "airpods_has_answered_onboarding"
    }

    // MARK: - Published State

    /// The user's self-reported AirPods ownership from onboarding
    @Published private(set) var selfReportedResponse: AirPodsOnboardingResponse? {
        didSet {
            if let response = selfReportedResponse {
                defaults.set(response.rawValue, forKey: Keys.selfReportedResponse)
                defaults.set(true, forKey: Keys.hasAnsweredOnboarding)
            } else {
                defaults.removeObject(forKey: Keys.selfReportedResponse)
                defaults.set(false, forKey: Keys.hasAnsweredOnboarding)
            }
        }
    }

    /// Whether the user has answered the onboarding question
    @Published private(set) var hasAnsweredOnboarding: Bool = false

    /// Last known detection state
    @Published private(set) var lastDetectedHeadphoneRoute: Bool = false

    /// When detection was last updated
    @Published private(set) var lastDetectionTimestamp: Date?

    // MARK: - Private

    private let defaults = UserDefaults.standard

    private init() {
        loadPersistedState()
    }

    // MARK: - Public Methods

    /// Record the user's response from onboarding.
    /// This is the primary method for setting the user's AirPods preference.
    func setOnboardingResponse(_ response: AirPodsOnboardingResponse) {
        self.selfReportedResponse = response

        // Track feature flag state change
        if response == .yes {
            AnalyticsService.shared.track(.airpodsPostureNudgesEnabled)
        }

        #if DEBUG
        print("🎧 [AirPodsStore] Saved onboarding response: \(response.rawValue)")
        #endif
    }

    /// Update from detection service when route changes.
    /// Called automatically by AirPodsDetectionService.
    func updateDetectionState(detected: Bool) {
        self.lastDetectedHeadphoneRoute = detected
        self.lastDetectionTimestamp = Date()

        defaults.set(detected, forKey: Keys.lastDetectedHeadphoneRoute)
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastDetectionTimestamp)

        #if DEBUG
        print("🎧 [AirPodsStore] Updated detection state: \(detected)")
        #endif
    }

    /// Reset the user's preference (for settings or debug).
    func resetPreference() {
        selfReportedResponse = nil
        hasAnsweredOnboarding = false
        defaults.removeObject(forKey: Keys.selfReportedResponse)
        defaults.set(false, forKey: Keys.hasAnsweredOnboarding)

        #if DEBUG
        print("🎧 [AirPodsStore] Reset user preference")
        #endif
    }

    /// Get the combined capability state for feature decisions.
    var capabilityState: AirPodsCapabilityState {
        AirPodsCapabilityState(
            selfReported: selfReportedResponse?.asBool,
            detectedNow: lastDetectedHeadphoneRoute,
            lastUpdated: lastDetectionTimestamp ?? Date()
        )
    }

    /// Bool convenience for self-reported value (nil for unknown).
    var airpodsSelfReported: Bool? {
        selfReportedResponse?.asBool
    }

    // MARK: - Private Methods

    private func loadPersistedState() {
        // Load self-reported response
        if let responseString = defaults.string(forKey: Keys.selfReportedResponse),
           let response = AirPodsOnboardingResponse(rawValue: responseString) {
            self.selfReportedResponse = response
        }

        // Load has answered flag
        self.hasAnsweredOnboarding = defaults.bool(forKey: Keys.hasAnsweredOnboarding)

        // Load last detection state
        self.lastDetectedHeadphoneRoute = defaults.bool(forKey: Keys.lastDetectedHeadphoneRoute)

        // Load last detection timestamp
        let timestamp = defaults.double(forKey: Keys.lastDetectionTimestamp)
        if timestamp > 0 {
            self.lastDetectionTimestamp = Date(timeIntervalSince1970: timestamp)
        }

        #if DEBUG
        print("🎧 [AirPodsStore] Loaded state: response=\(selfReportedResponse?.rawValue ?? "nil"), hasAnswered=\(hasAnsweredOnboarding), lastDetected=\(lastDetectedHeadphoneRoute)")
        #endif
    }
}
