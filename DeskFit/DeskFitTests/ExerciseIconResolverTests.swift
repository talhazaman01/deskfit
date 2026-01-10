//
//  ExerciseIconResolverTests.swift
//  DeskFitTests
//
//  Tests for ExerciseIconResolver to ensure correct icon mapping for all exercises.
//

import Testing
@testable import DeskFit

struct ExerciseIconResolverTests {

    // MARK: - Helper to create test exercises

    static func makeExercise(
        id: String,
        name: String = "Test Exercise",
        focusAreas: [String] = [],
        intentTags: [String]? = nil
    ) -> Exercise {
        Exercise(
            id: id,
            name: name,
            description: "Test description",
            cue: "Test cue",
            durationSeconds: 30,
            focusAreas: focusAreas,
            difficulty: "easy",
            imageAsset: "",
            animationAsset: nil,
            contraindication: "None",
            issueTags: nil,
            intentTags: intentTags,
            contextTags: nil,
            equipment: nil
        )
    }

    // MARK: - Explicit Mapping Tests

    @Test("Deep breathing exercise maps to breathing icon")
    func deepBreathingMapsToBreathingIcon() {
        let exercise = makeExercise(
            id: "deep_breathing",
            focusAreas: ["upper_back"],
            intentTags: ["breathing", "decompression"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .breathing)
        #expect(iconKey.sfSymbolName == "wind")
    }

    @Test("Eye palming exercise maps to eye care icon")
    func eyePalmingMapsToEyeCareIcon() {
        let exercise = makeExercise(
            id: "eye_palming",
            focusAreas: ["neck"],
            intentTags: ["decompression", "breathing"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .eyeCare)
        #expect(iconKey.sfSymbolName == "eye")
    }

    // MARK: - Neck Exercise Tests

    @Test("Neck stretch exercise maps correctly")
    func neckStretchMapsCorrectly() {
        let exercise = makeExercise(
            id: "neck_side_stretch",
            focusAreas: ["neck", "shoulders"],
            intentTags: ["stretching", "decompression"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .neckStretch)
    }

    @Test("Neck strength exercise maps correctly")
    func neckStrengthMapsCorrectly() {
        let exercise = makeExercise(
            id: "chin_tucks",
            focusAreas: ["neck", "upper_back"],
            intentTags: ["strengthening", "activation"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .neckStrength)
    }

    @Test("Neck mobility exercise maps correctly")
    func neckMobilityMapsCorrectly() {
        let exercise = makeExercise(
            id: "neck_rolls",
            focusAreas: ["neck"],
            intentTags: ["mobility", "decompression"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .neckMobility)
    }

    // MARK: - Shoulder Exercise Tests

    @Test("Shoulder stretch exercise maps correctly")
    func shoulderStretchMapsCorrectly() {
        let exercise = makeExercise(
            id: "chest_opener",
            focusAreas: ["shoulders", "upper_back"],
            intentTags: ["stretching", "decompression"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .shoulderStretch)
    }

    @Test("Shoulder strength exercise maps correctly")
    func shoulderStrengthMapsCorrectly() {
        let exercise = makeExercise(
            id: "desk_pushups",
            focusAreas: ["shoulders", "upper_back"],
            intentTags: ["strengthening", "activation"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .shoulderStrength)
    }

    @Test("Shoulder mobility exercise maps correctly")
    func shoulderMobilityMapsCorrectly() {
        let exercise = makeExercise(
            id: "shoulder_rolls",
            focusAreas: ["shoulders", "upper_back"],
            intentTags: ["mobility", "activation"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .shoulderMobility)
    }

    // MARK: - Upper Back Exercise Tests

    @Test("Upper back stretch exercise maps correctly")
    func upperBackStretchMapsCorrectly() {
        let exercise = makeExercise(
            id: "upper_trap_stretch",
            focusAreas: ["upper_back", "neck", "shoulders"],
            intentTags: ["stretching", "decompression"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .upperBackStretch)
    }

    @Test("Upper back mobility exercise maps correctly")
    func upperBackMobilityMapsCorrectly() {
        let exercise = makeExercise(
            id: "cat_cow_seated",
            focusAreas: ["upper_back", "lower_back"],
            intentTags: ["mobility", "breathing"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .upperBackMobility)
    }

    // MARK: - Lower Back Exercise Tests

    @Test("Lower back stretch exercise maps correctly")
    func lowerBackStretchMapsCorrectly() {
        let exercise = makeExercise(
            id: "seated_forward_fold",
            focusAreas: ["lower_back", "upper_back"],
            intentTags: ["stretching", "decompression"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .lowerBackStretch)
    }

    @Test("Lower back mobility exercise maps correctly")
    func lowerBackMobilityMapsCorrectly() {
        let exercise = makeExercise(
            id: "pelvic_tilt",
            focusAreas: ["lower_back", "hips"],
            intentTags: ["mobility", "activation"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .lowerBackMobility)
    }

    // MARK: - Wrist Exercise Tests

    @Test("Wrist stretch exercise maps correctly")
    func wristStretchMapsCorrectly() {
        let exercise = makeExercise(
            id: "wrist_flexor_stretch",
            focusAreas: ["wrists"],
            intentTags: ["stretching"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .wristStretch)
    }

    @Test("Wrist mobility exercise maps correctly")
    func wristMobilityMapsCorrectly() {
        let exercise = makeExercise(
            id: "wrist_circles",
            focusAreas: ["wrists"],
            intentTags: ["mobility", "activation"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .wristMobility)
    }

    // MARK: - Hip Exercise Tests

    @Test("Hip stretch exercise maps correctly")
    func hipStretchMapsCorrectly() {
        let exercise = makeExercise(
            id: "seated_hip_stretch",
            focusAreas: ["hips", "lower_back"],
            intentTags: ["stretching", "decompression"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .hipStretch)
    }

    @Test("Hip strength exercise maps correctly")
    func hipStrengthMapsCorrectly() {
        let exercise = makeExercise(
            id: "glute_bridge",
            focusAreas: ["hips", "lower_back"],
            intentTags: ["strengthening", "activation"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .hipStrength)
    }

    @Test("Hip mobility exercise maps correctly")
    func hipMobilityMapsCorrectly() {
        let exercise = makeExercise(
            id: "hip_circles",
            focusAreas: ["hips"],
            intentTags: ["mobility"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .hipMobility)
    }

    // MARK: - Fallback Tests

    @Test("Exercise with no focus areas falls back to generic movement")
    func noFocusAreasFallsBackToGeneric() {
        let exercise = makeExercise(
            id: "unknown_exercise",
            focusAreas: [],
            intentTags: ["mobility"]
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .genericMovement)
    }

    @Test("Exercise with unknown focus area falls back to generic movement")
    func unknownFocusAreaFallsBackToGeneric() {
        let exercise = makeExercise(
            id: "unknown_exercise",
            focusAreas: ["unknown_area"],
            intentTags: nil
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .genericMovement)
    }

    @Test("Exercise with focus area but no intents uses body area default")
    func focusAreaWithNoIntentsUsesDefault() {
        let exercise = makeExercise(
            id: "basic_neck",
            focusAreas: ["neck"],
            intentTags: nil
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .neckStretch)
    }

    // MARK: - SF Symbol Tests

    @Test("All icon keys have valid SF Symbol names")
    func allIconKeysHaveValidSymbolNames() {
        for iconKey in IconKey.allCases {
            let symbolName = iconKey.sfSymbolName
            #expect(!symbolName.isEmpty)
        }
    }

    @Test("All icon keys have accessibility labels")
    func allIconKeysHaveAccessibilityLabels() {
        for iconKey in IconKey.allCases {
            let label = iconKey.accessibilityLabel
            #expect(!label.isEmpty)
            #expect(label.contains("exercise"))
        }
    }

    // MARK: - Determinism Tests

    @Test("Same exercise always produces same icon key")
    func iconResolutionIsDeterministic() {
        let exercise = makeExercise(
            id: "test_exercise",
            focusAreas: ["neck", "shoulders"],
            intentTags: ["stretching", "mobility"]
        )

        let key1 = ExerciseIconResolver.iconKey(for: exercise)
        let key2 = ExerciseIconResolver.iconKey(for: exercise)
        let key3 = ExerciseIconResolver.iconKey(for: exercise)

        #expect(key1 == key2)
        #expect(key2 == key3)
    }

    // MARK: - Extension Tests

    @Test("Exercise extension provides iconKey property")
    func exerciseExtensionProvidesIconKey() {
        let exercise = makeExercise(
            id: "neck_rolls",
            focusAreas: ["neck"],
            intentTags: ["mobility"]
        )

        #expect(exercise.iconKey == .neckMobility)
    }

    @Test("Exercise extension provides iconName property")
    func exerciseExtensionProvidesIconName() {
        let exercise = makeExercise(
            id: "neck_rolls",
            focusAreas: ["neck"],
            intentTags: ["mobility"]
        )

        #expect(exercise.iconName == "figure.cooldown")
    }

    @Test("Exercise extension provides iconAccessibilityLabel property")
    func exerciseExtensionProvidesAccessibilityLabel() {
        let exercise = makeExercise(
            id: "neck_rolls",
            focusAreas: ["neck"],
            intentTags: ["mobility"]
        )

        #expect(exercise.iconAccessibilityLabel == "Neck mobility exercise")
    }

    // MARK: - Priority Tests

    @Test("Explicit mapping takes priority over derived")
    func explicitMappingTakesPriority() {
        // deep_breathing has upper_back focus but should still get breathing icon
        let exercise = makeExercise(
            id: "deep_breathing",
            focusAreas: ["upper_back"],
            intentTags: ["stretching"] // Even with stretching intent, should get breathing
        )

        let iconKey = ExerciseIconResolver.iconKey(for: exercise)

        #expect(iconKey == .breathing)
    }

    @Test("Intent-based derivation takes priority over body area only")
    func intentBasedTakesPriorityOverBodyAreaOnly() {
        let stretchExercise = makeExercise(
            id: "neck_stretch_test",
            focusAreas: ["neck"],
            intentTags: ["stretching"]
        )

        let strengthExercise = makeExercise(
            id: "neck_strength_test",
            focusAreas: ["neck"],
            intentTags: ["strengthening"]
        )

        #expect(ExerciseIconResolver.iconKey(for: stretchExercise) == .neckStretch)
        #expect(ExerciseIconResolver.iconKey(for: strengthExercise) == .neckStrength)
    }
}
