import Foundation
import AVFoundation
import Combine

// MARK: - README / Key Design Decisions
// =====================================
// DETECTION IS A HINT, NOT ABSOLUTE TRUTH:
// - Users may own AirPods but not have them connected right now.
// - Detection should only influence defaults and UI hints, never force an answer.
// - The self-reported value (from onboarding) is the source of truth for feature gating.
//
// IMPLEMENTATION:
// - Uses AVAudioSession to inspect currentRoute outputs for headphone-class devices.
// - Listens for route changes to update detection state in real-time.
// - Safe for @MainActor UI updates via @Published properties.
//
// ROUTE TYPES CONSIDERED "HEADPHONE CAPABLE":
// - .headphones (wired headphones)
// - .bluetoothA2DP (Bluetooth audio, including AirPods)
// - .bluetoothHFP (Bluetooth hands-free)
// - .bluetoothLE (Bluetooth Low Energy audio)
// =====================================

/// Represents the detected headphone route type
enum DetectedRouteType: String, Sendable {
    case none = "none"
    case wired = "wired"
    case bluetoothA2DP = "bluetooth_a2dp"
    case bluetoothHFP = "bluetooth_hfp"
    case bluetoothLE = "bluetooth_le"
    case airPlay = "airplay"  // Treated separately (external audio, not personal headphones)
    case unknown = "unknown"

    /// Whether this route type represents personal headphones (not external speakers)
    var isHeadphoneCapable: Bool {
        switch self {
        case .wired, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
            return true
        case .none, .airPlay, .unknown:
            return false
        }
    }
}

/// Service that detects whether headphones (including AirPods) are connected.
/// Detection is "best effort" - it's a hint for UI, not a gating mechanism.
@MainActor
final class AirPodsDetectionService: ObservableObject {
    static let shared = AirPodsDetectionService()

    // MARK: - Published State

    /// Whether a headphone-capable route is currently detected
    @Published private(set) var isHeadphoneDetected: Bool = false

    /// The type of route currently detected
    @Published private(set) var detectedRouteType: DetectedRouteType = .none

    /// Human-readable description of the current route (for debugging/display)
    @Published private(set) var routeDescription: String = ""

    /// When the detection was last updated
    @Published private(set) var lastUpdated: Date = Date()

    // MARK: - Private

    private var isListening = false

    private init() {
        // Perform initial detection
        updateDetectionState()
    }

    // MARK: - Public Methods

    /// Start listening for audio route changes.
    /// Call this on app launch to keep detection up-to-date.
    func startListening() {
        guard !isListening else { return }
        isListening = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )

        // Update state immediately
        updateDetectionState()

        #if DEBUG
        print("🎧 [AirPodsDetection] Started listening for route changes")
        #endif
    }

    /// Stop listening for audio route changes.
    func stopListening() {
        guard isListening else { return }
        isListening = false

        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )

        #if DEBUG
        print("🎧 [AirPodsDetection] Stopped listening for route changes")
        #endif
    }

    /// Force a manual refresh of the detection state.
    func refreshDetection() {
        updateDetectionState()
    }

    // MARK: - Private Methods

    @objc private func handleRouteChange(_ notification: Notification) {
        // Dispatch to main actor for UI updates
        Task { @MainActor in
            self.updateDetectionState()

            // Log the reason for route change (useful for debugging)
            #if DEBUG
            if let userInfo = notification.userInfo,
               let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
               let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) {
                let reasonString = self.routeChangeReasonDescription(reason)
                print("🎧 [AirPodsDetection] Route changed: \(reasonString)")
            }
            #endif
        }
    }

    private func updateDetectionState() {
        let session = AVAudioSession.sharedInstance()
        let currentRoute = session.currentRoute

        // Analyze outputs to find headphone-class devices
        var foundRouteType: DetectedRouteType = .none
        var routeDescriptions: [String] = []

        for output in currentRoute.outputs {
            let portType = output.portType
            let portName = output.portName

            routeDescriptions.append("\(portName) (\(portType.rawValue))")

            // Determine route type based on port type
            let detectedType = mapPortTypeToRouteType(portType)

            // Prefer headphone-capable routes over non-headphone routes
            if detectedType.isHeadphoneCapable && !foundRouteType.isHeadphoneCapable {
                foundRouteType = detectedType
            } else if foundRouteType == .none {
                foundRouteType = detectedType
            }
        }

        // Update published state
        self.detectedRouteType = foundRouteType
        self.isHeadphoneDetected = foundRouteType.isHeadphoneCapable
        self.routeDescription = routeDescriptions.joined(separator: ", ")
        self.lastUpdated = Date()

        #if DEBUG
        print("🎧 [AirPodsDetection] Updated: headphones=\(isHeadphoneDetected), type=\(detectedRouteType.rawValue), route=\(routeDescription)")
        #endif

        // Track analytics
        AnalyticsService.shared.track(.airpodsRouteDetected(
            detected: isHeadphoneDetected,
            routeType: detectedRouteType.rawValue
        ))
    }

    private func mapPortTypeToRouteType(_ portType: AVAudioSession.Port) -> DetectedRouteType {
        switch portType {
        case .headphones:
            return .wired
        case .bluetoothA2DP:
            return .bluetoothA2DP
        case .bluetoothHFP:
            return .bluetoothHFP
        case .bluetoothLE:
            return .bluetoothLE
        case .airPlay:
            return .airPlay
        case .builtInSpeaker, .builtInReceiver:
            return .none
        default:
            // For unknown port types, check if it might be Bluetooth
            if portType.rawValue.lowercased().contains("bluetooth") {
                return .bluetoothA2DP
            }
            return .unknown
        }
    }

    #if DEBUG
    private func routeChangeReasonDescription(_ reason: AVAudioSession.RouteChangeReason) -> String {
        switch reason {
        case .newDeviceAvailable:
            return "New device available"
        case .oldDeviceUnavailable:
            return "Old device unavailable"
        case .categoryChange:
            return "Category change"
        case .override:
            return "Override"
        case .wakeFromSleep:
            return "Wake from sleep"
        case .noSuitableRouteForCategory:
            return "No suitable route"
        case .routeConfigurationChange:
            return "Configuration change"
        case .unknown:
            return "Unknown"
        @unknown default:
            return "Unknown (new case)"
        }
    }
    #endif
}
