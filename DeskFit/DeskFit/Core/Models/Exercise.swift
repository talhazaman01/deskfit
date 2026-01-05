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

    // MARK: - Enhanced Tags for Plan Generation

    /// Posture issues this exercise helps address
    /// e.g., ["forward_head", "rounded_shoulders"]
    let issueTags: [String]?

    /// Intent/purpose of the exercise
    /// e.g., ["mobility", "stretching", "activation"]
    let intentTags: [String]?

    /// Best context for this exercise
    /// e.g., ["desk", "morning", "microbreak"]
    let contextTags: [String]?

    /// Equipment required (if any)
    /// e.g., "chair", "wall", "doorway", "desk", "none"
    let equipment: String?

    // MARK: - Initializer (with defaults for optional tag/equipment params)

    init(
        id: String,
        name: String,
        description: String,
        cue: String,
        durationSeconds: Int,
        focusAreas: [String],
        difficulty: String,
        imageAsset: String,
        animationAsset: String?,
        contraindication: String,
        issueTags: [String]? = nil,
        intentTags: [String]? = nil,
        contextTags: [String]? = nil,
        equipment: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.cue = cue
        self.durationSeconds = durationSeconds
        self.focusAreas = focusAreas
        self.difficulty = difficulty
        self.imageAsset = imageAsset
        self.animationAsset = animationAsset
        self.contraindication = contraindication
        self.issueTags = issueTags
        self.intentTags = intentTags
        self.contextTags = contextTags
        self.equipment = equipment
    }

    // MARK: - Computed Properties

    var hasImage: Bool {
        false
    }

    /// Typed difficulty enum
    var difficultyEnum: ExerciseDifficulty {
        ExerciseDifficulty(rawValue: difficulty) ?? .easy
    }

    /// Typed focus areas
    var focusAreasEnum: [FocusArea] {
        focusAreas.compactMap { FocusArea(rawValue: $0) }
    }

    /// Typed issue tags
    var issueTagsEnum: [ExerciseIssueTag] {
        (issueTags ?? []).compactMap { ExerciseIssueTag(rawValue: $0) }
    }

    /// Typed intent tags
    var intentTagsEnum: [ExerciseIntentTag] {
        (intentTags ?? []).compactMap { ExerciseIntentTag(rawValue: $0) }
    }

    /// Typed context tags
    var contextTagsEnum: [ExerciseContextTag] {
        (contextTags ?? []).compactMap { ExerciseContextTag(rawValue: $0) }
    }

    /// Typed equipment
    var equipmentEnum: ExerciseEquipment {
        guard let eq = equipment else { return .none }
        return ExerciseEquipment(rawValue: eq) ?? .none
    }

    /// Whether this exercise is desk-friendly (can be done at/near desk)
    var isDeskFriendly: Bool {
        let deskContext = contextTagsEnum.contains(.desk) || contextTagsEnum.contains(.microbreak)
        let deskEquipment = equipmentEnum == .none || equipmentEnum == .chair || equipmentEnum == .desk
        return deskContext || deskEquipment
    }

    /// Combined relevance score for a given set of criteria
    func relevanceScore(
        forFocusAreas targetFocusAreas: Set<FocusArea>,
        painAreas: Set<PainArea>,
        postureIssues: Set<PostureIssue>,
        stiffnessTimes: Set<StiffnessTime>
    ) -> Int {
        var score = 0

        // Focus area match (primary)
        let focusMatch = Set(focusAreasEnum).intersection(targetFocusAreas).count
        score += focusMatch * 3

        // Pain area match (high priority)
        let painRelatedFocusAreas = painAreas.flatMap { $0.relatedFocusAreas }
        let painMatch = Set(focusAreasEnum).intersection(Set(painRelatedFocusAreas)).count
        score += painMatch * 4

        // Posture issue match (high priority)
        let postureIssueTags = postureIssues.flatMap { $0.exerciseIssueTags }
        let issueMatch = Set(issueTagsEnum).intersection(Set(postureIssueTags)).count
        score += issueMatch * 4

        // Stiffness time context match
        for stiffnessTime in stiffnessTimes {
            switch stiffnessTime {
            case .morning where contextTagsEnum.contains(.morning):
                score += 2
            case .midday where contextTagsEnum.contains(.midday):
                score += 2
            case .evening where contextTagsEnum.contains(.evening):
                score += 2
            default:
                break
            }
        }

        return score
    }
}

struct ExerciseLibrary: Codable {
    let version: String
    let exercises: [Exercise]
}
