import Foundation

// MARK: - Icon Key

/// All possible exercise icon keys, representing specific body area + movement type combinations
enum IconKey: String, CaseIterable {
    // Neck
    case neckStretch
    case neckStrength
    case neckMobility

    // Shoulders
    case shoulderStretch
    case shoulderStrength
    case shoulderMobility

    // Upper Back
    case upperBackStretch
    case upperBackStrength
    case upperBackMobility

    // Lower Back
    case lowerBackStretch
    case lowerBackStrength
    case lowerBackMobility

    // Wrists
    case wristStretch
    case wristMobility

    // Hips
    case hipStretch
    case hipStrength
    case hipMobility

    // Special categories
    case breathing
    case postureReset
    case eyeCare
    case fullBodyStretch
    case genericMovement

    /// The SF Symbol name for this icon key
    var sfSymbolName: String {
        switch self {
        // Neck icons - using head/neck-related symbols
        case .neckStretch:
            return "figure.mind.and.body"
        case .neckStrength:
            return "figure.strengthtraining.traditional"
        case .neckMobility:
            return "figure.cooldown"

        // Shoulder icons - using arm/shoulder-related symbols
        case .shoulderStretch:
            return "figure.arms.open"
        case .shoulderStrength:
            return "figure.strengthtraining.functional"
        case .shoulderMobility:
            return "figure.mixed.cardio"

        // Upper Back icons
        case .upperBackStretch:
            return "figure.roll"
        case .upperBackStrength:
            return "figure.core.training"
        case .upperBackMobility:
            return "figure.flexibility"

        // Lower Back icons
        case .lowerBackStretch:
            return "figure.flexibility"
        case .lowerBackStrength:
            return "figure.core.training"
        case .lowerBackMobility:
            return "figure.pilates"

        // Wrist icons
        case .wristStretch:
            return "hand.raised.fingers.spread"
        case .wristMobility:
            return "hands.and.sparkles"

        // Hip icons
        case .hipStretch:
            return "figure.walk"
        case .hipStrength:
            return "figure.stairs"
        case .hipMobility:
            return "figure.run"

        // Special categories
        case .breathing:
            return "wind"
        case .postureReset:
            return "figure.stand"
        case .eyeCare:
            return "eye"
        case .fullBodyStretch:
            return "figure.yoga"
        case .genericMovement:
            return "figure.flexibility"
        }
    }

    /// Accessibility label for the icon
    var accessibilityLabel: String {
        switch self {
        case .neckStretch: return "Neck stretch exercise"
        case .neckStrength: return "Neck strengthening exercise"
        case .neckMobility: return "Neck mobility exercise"
        case .shoulderStretch: return "Shoulder stretch exercise"
        case .shoulderStrength: return "Shoulder strengthening exercise"
        case .shoulderMobility: return "Shoulder mobility exercise"
        case .upperBackStretch: return "Upper back stretch exercise"
        case .upperBackStrength: return "Upper back strengthening exercise"
        case .upperBackMobility: return "Upper back mobility exercise"
        case .lowerBackStretch: return "Lower back stretch exercise"
        case .lowerBackStrength: return "Lower back strengthening exercise"
        case .lowerBackMobility: return "Lower back mobility exercise"
        case .wristStretch: return "Wrist stretch exercise"
        case .wristMobility: return "Wrist mobility exercise"
        case .hipStretch: return "Hip stretch exercise"
        case .hipStrength: return "Hip strengthening exercise"
        case .hipMobility: return "Hip mobility exercise"
        case .breathing: return "Breathing exercise"
        case .postureReset: return "Posture reset exercise"
        case .eyeCare: return "Eye care exercise"
        case .fullBodyStretch: return "Full body stretch exercise"
        case .genericMovement: return "Movement exercise"
        }
    }
}

// MARK: - Exercise Icon Resolver

/// Single source of truth for resolving exercise icons.
/// Uses a priority-based system to derive the most appropriate icon for any exercise.
struct ExerciseIconResolver {

    // MARK: - Static Mappings for Special Exercises

    /// Exercise IDs that have explicit icon overrides
    private static let explicitIconMappings: [String: IconKey] = [
        "deep_breathing": .breathing,
        "eye_palming": .eyeCare
    ]

    // MARK: - Public API

    /// Resolves the icon key for a given exercise using priority-based rules:
    /// 1. Explicit mapping (if exercise ID is in explicitIconMappings)
    /// 2. Derived from primary intent + primary body area
    /// 3. Derived from primary body area alone
    /// 4. Fallback to genericMovement
    static func iconKey(for exercise: Exercise) -> IconKey {
        // Priority 1: Check for explicit mapping
        if let explicitKey = explicitIconMappings[exercise.id] {
            return explicitKey
        }

        // Priority 2: Derive from intent + body area
        if let derivedKey = deriveFromIntentAndArea(exercise: exercise) {
            return derivedKey
        }

        // Priority 3: Derive from body area alone
        if let areaKey = deriveFromBodyAreaOnly(exercise: exercise) {
            return areaKey
        }

        // Priority 4: Final fallback
        return .genericMovement
    }

    /// Returns the SF Symbol name for a given exercise
    static func sfSymbolName(for exercise: Exercise) -> String {
        return iconKey(for: exercise).sfSymbolName
    }

    /// Returns the accessibility label for a given exercise icon
    static func accessibilityLabel(for exercise: Exercise) -> String {
        return iconKey(for: exercise).accessibilityLabel
    }

    // MARK: - Private Derivation Logic

    /// Derives icon key from the combination of primary intent and primary body area
    private static func deriveFromIntentAndArea(exercise: Exercise) -> IconKey? {
        let intents = exercise.intentTagsEnum
        let areas = exercise.focusAreasEnum

        guard let primaryArea = areas.first else { return nil }

        // Determine primary movement type from intents
        let isStretch = intents.contains(.stretching) || intents.contains(.decompression)
        let isStrength = intents.contains(.strengthening)
        let isMobility = intents.contains(.mobility)
        let isBreathing = intents.contains(.breathing)
        let isActivation = intents.contains(.activation)

        // Special case: Breathing exercises
        if isBreathing && !isStretch && !isStrength && !isMobility {
            return .breathing
        }

        // Map based on body area + movement type
        switch primaryArea {
        case .neck:
            if isStretch { return .neckStretch }
            if isStrength || isActivation { return .neckStrength }
            if isMobility { return .neckMobility }
            return .neckStretch // Default for neck

        case .shoulders:
            if isStretch { return .shoulderStretch }
            if isStrength || isActivation { return .shoulderStrength }
            if isMobility { return .shoulderMobility }
            return .shoulderStretch // Default for shoulders

        case .upperBack:
            if isStretch { return .upperBackStretch }
            if isStrength || isActivation { return .upperBackStrength }
            if isMobility { return .upperBackMobility }
            return .upperBackStretch // Default for upper back

        case .lowerBack:
            if isStretch { return .lowerBackStretch }
            if isStrength || isActivation { return .lowerBackStrength }
            if isMobility { return .lowerBackMobility }
            return .lowerBackStretch // Default for lower back

        case .wrists:
            if isStretch { return .wristStretch }
            return .wristMobility // Wrists mainly do stretch or mobility

        case .hips:
            if isStretch { return .hipStretch }
            if isStrength || isActivation { return .hipStrength }
            if isMobility { return .hipMobility }
            return .hipStretch // Default for hips
        }
    }

    /// Derives icon key from body area only (fallback when intent is unclear)
    private static func deriveFromBodyAreaOnly(exercise: Exercise) -> IconKey? {
        guard let primaryArea = exercise.focusAreasEnum.first else { return nil }

        // Default to stretch variant for each body area
        switch primaryArea {
        case .neck: return .neckStretch
        case .shoulders: return .shoulderStretch
        case .upperBack: return .upperBackStretch
        case .lowerBack: return .lowerBackStretch
        case .wrists: return .wristStretch
        case .hips: return .hipStretch
        }
    }
}

// MARK: - Exercise Extension for Icon Access

extension Exercise {
    /// The resolved icon key for this exercise
    var iconKey: IconKey {
        ExerciseIconResolver.iconKey(for: self)
    }

    /// The SF Symbol name for this exercise's icon
    var iconName: String {
        ExerciseIconResolver.sfSymbolName(for: self)
    }

    /// Accessibility label for this exercise's icon
    var iconAccessibilityLabel: String {
        ExerciseIconResolver.accessibilityLabel(for: self)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension ExerciseIconResolver {
    /// Returns a debug description of how an exercise's icon was resolved
    static func debugDescription(for exercise: Exercise) -> String {
        let key = iconKey(for: exercise)
        let areas = exercise.focusAreasEnum.map { $0.rawValue }.joined(separator: ", ")
        let intents = exercise.intentTagsEnum.map { $0.rawValue }.joined(separator: ", ")

        return """
        Exercise: \(exercise.name) (\(exercise.id))
        Focus Areas: [\(areas)]
        Intents: [\(intents)]
        Resolved Icon: \(key.rawValue) -> \(key.sfSymbolName)
        """
    }

    /// Validates that all exercises have appropriate icons (not just genericMovement unless intentional)
    static func validateCatalog(exercises: [Exercise]) -> [(exercise: Exercise, issue: String)] {
        var issues: [(Exercise, String)] = []

        for exercise in exercises {
            let key = iconKey(for: exercise)

            // Check if falling back to generic when we shouldn't
            if key == .genericMovement && !exercise.focusAreasEnum.isEmpty {
                issues.append((exercise, "Has focus areas but resolved to genericMovement"))
            }
        }

        return issues
    }
}
#endif
