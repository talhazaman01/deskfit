import SwiftUI
import Combine

// MARK: - Session Coordinator Protocol

/// Protocol for tab-scoped session coordinators.
/// Each tab (Home, Training) has its own coordinator to manage session presentation independently.
protocol SessionCoordinating: ObservableObject {
    var activeSession: PlannedSession? { get set }
    var sourceTab: String { get }

    func startSession(_ session: PlannedSession)
    func endSession()
}

// MARK: - Home Session Coordinator

/// Manages session presentation for the Home tab.
/// Owns the presentation state so Home-initiated sessions stay within Home's context.
@MainActor
final class HomeSessionCoordinator: ObservableObject, SessionCoordinating {
    @Published var activeSession: PlannedSession?

    let sourceTab = "home"

    func startSession(_ session: PlannedSession) {
        activeSession = session
    }

    func endSession() {
        activeSession = nil
    }
}

// MARK: - Training Session Coordinator

/// Manages session presentation for the Training tab.
/// Owns the presentation state so Training-initiated sessions stay within Training's context.
@MainActor
final class TrainingSessionCoordinator: ObservableObject, SessionCoordinating {
    @Published var activeSession: PlannedSession?

    let sourceTab = "training"

    func startSession(_ session: PlannedSession) {
        activeSession = session
    }

    func endSession() {
        activeSession = nil
    }
}
