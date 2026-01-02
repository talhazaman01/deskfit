import Foundation

struct Exercise: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let cue: String
    let durationSeconds: Int
    let focusAreas: [String]
    let difficulty: String
    let imageAsset: String
    let animationAsset: String?

    /// Safety note shown before/during exercise
    /// e.g., "Stop if you feel dizzy or experience any pain"
    let contraindication: String

    // TODO: Add actual image assets to Assets.xcassets
    var hasImage: Bool {
        false
    }
}

struct ExerciseLibrary: Codable {
    let version: String
    let exercises: [Exercise]
}
