import Foundation
import SwiftData

@Model
final class SessionRecord {
    var id: UUID
    var completedAt: Date
    var durationSeconds: Int
    var sessionType: String
    var exerciseIds: [String]
    var feedback: String?
    var focusAreas: [String]

    init(
        sessionType: String,
        durationSeconds: Int,
        exerciseIds: [String],
        focusAreas: [String],
        feedback: String? = nil
    ) {
        self.id = UUID()
        self.completedAt = Date()
        self.durationSeconds = durationSeconds
        self.sessionType = sessionType
        self.exerciseIds = exerciseIds
        self.focusAreas = focusAreas
        self.feedback = feedback
    }
}
