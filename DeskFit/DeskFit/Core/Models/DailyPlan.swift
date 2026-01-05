import Foundation
import SwiftData

@Model
final class DailyPlan {
    var id: UUID
    var date: Date
    var generatedAt: Date

    // Stored as JSON Data for reliable persistence
    private var sessionsJSON: Data

    var sessions: [PlannedSession] {
        get {
            guard !sessionsJSON.isEmpty else { return [] }
            do {
                return try JSONDecoder().decode([PlannedSession].self, from: sessionsJSON)
            } catch {
                print("Failed to decode sessions: \(error)")
                return []
            }
        }
        set {
            do {
                sessionsJSON = try JSONEncoder().encode(newValue)
            } catch {
                print("Failed to encode sessions: \(error)")
                sessionsJSON = Data()
            }
        }
    }

    init(date: Date, sessions: [PlannedSession]) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.generatedAt = Date()

        do {
            self.sessionsJSON = try JSONEncoder().encode(sessions)
        } catch {
            self.sessionsJSON = Data()
        }
    }

    func updateSession(_ session: PlannedSession) {
        var currentSessions = sessions
        if let index = currentSessions.firstIndex(where: { $0.id == session.id }) {
            currentSessions[index] = session
            sessions = currentSessions
        }
    }

    func markSessionCompleted(sessionId: UUID) {
        var currentSessions = sessions
        if let index = currentSessions.firstIndex(where: { $0.id == sessionId }) {
            currentSessions[index].isCompleted = true
            currentSessions[index].completedAt = Date()
            sessions = currentSessions
        }
    }
}

struct PlannedSession: Codable, Hashable, Identifiable {
    var id: UUID
    var type: SessionType
    var title: String
    var exerciseIds: [String]
    var durationSeconds: Int
    var isCompleted: Bool
    var completedAt: Date?

    init(type: SessionType, exerciseIds: [String], durationSeconds: Int) {
        self.id = UUID()
        self.type = type
        self.title = type.displayName
        self.exerciseIds = exerciseIds
        self.durationSeconds = durationSeconds
        self.isCompleted = false
        self.completedAt = nil
    }

    mutating func markCompleted() {
        isCompleted = true
        completedAt = Date()
    }
}

enum SessionType: String, Codable, Sendable {
    case morning
    case midday
    case afternoon

    var displayName: String {
        switch self {
        case .morning: return "Morning Reset"
        case .midday: return "Midday Refresh"
        case .afternoon: return "Afternoon Stretch"
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .afternoon: return "sunset.fill"
        }
    }
}
