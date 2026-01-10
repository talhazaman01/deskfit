//
//  ExerciseCatalogCompletenessTests.swift
//  DeskFitTests
//
//  Tests to ensure all exercises in the catalog have appropriate icon mappings.
//

import Testing
@testable import DeskFit

struct ExerciseCatalogCompletenessTests {

    // MARK: - Catalog Access

    private var allExercises: [Exercise] {
        ExerciseService.shared.getAllExercises()
    }

    // MARK: - Completeness Tests

    @Test("All exercises have non-empty focus areas")
    func allExercisesHaveFocusAreas() {
        for exercise in allExercises {
            #expect(!exercise.focusAreas.isEmpty, "Exercise '\(exercise.name)' (\(exercise.id)) has no focus areas")
        }
    }

    @Test("All exercises resolve to a valid icon key")
    func allExercisesResolveToValidIconKey() {
        for exercise in allExercises {
            let iconKey = ExerciseIconResolver.iconKey(for: exercise)

            // Should never return nil (it won't since we return IconKey)
            #expect(IconKey.allCases.contains(iconKey), "Exercise '\(exercise.name)' resolved to invalid icon key")
        }
    }

    @Test("No exercise resolves to generic movement unless intentional")
    func noExerciseResolvesToGenericMovementUnlessIntentional() {
        // Exercises that are allowed to be generic (if any)
        let allowedGenericIds: Set<String> = []

        for exercise in allExercises {
            let iconKey = ExerciseIconResolver.iconKey(for: exercise)

            if iconKey == .genericMovement && !allowedGenericIds.contains(exercise.id) {
                // This is a failure - exercise should have a specific icon
                Issue.record("Exercise '\(exercise.name)' (\(exercise.id)) unexpectedly resolved to genericMovement. " +
                           "Focus areas: \(exercise.focusAreas), " +
                           "Intent tags: \(exercise.intentTags ?? [])")
            }
        }
    }

    @Test("All SF Symbol names are valid")
    func allSFSymbolNamesAreValid() {
        for exercise in allExercises {
            let symbolName = exercise.iconName

            #expect(!symbolName.isEmpty, "Exercise '\(exercise.name)' has empty SF Symbol name")
            #expect(!symbolName.contains(" "), "Exercise '\(exercise.name)' has invalid SF Symbol name with spaces")
        }
    }

    @Test("All exercises have accessibility labels")
    func allExercisesHaveAccessibilityLabels() {
        for exercise in allExercises {
            let label = exercise.iconAccessibilityLabel

            #expect(!label.isEmpty, "Exercise '\(exercise.name)' has empty accessibility label")
        }
    }

    // MARK: - Body Area Coverage Tests

    @Test("Neck exercises have neck-related icons")
    func neckExercisesHaveNeckIcons() {
        let neckExercises = allExercises.filter { $0.focusAreas.contains("neck") }

        let neckIconKeys: Set<IconKey> = [
            .neckStretch, .neckStrength, .neckMobility,
            .breathing, .eyeCare // Special cases
        ]

        for exercise in neckExercises {
            let iconKey = exercise.iconKey

            // Primary neck exercises should have neck-related icons
            // (but if neck is secondary, might have different primary icon)
            if exercise.focusAreas.first == "neck" {
                #expect(neckIconKeys.contains(iconKey),
                       "Primary neck exercise '\(exercise.name)' has non-neck icon: \(iconKey)")
            }
        }
    }

    @Test("Shoulder exercises have shoulder-related icons")
    func shoulderExercisesHaveShoulderIcons() {
        let shoulderExercises = allExercises.filter { $0.focusAreas.first == "shoulders" }

        let shoulderIconKeys: Set<IconKey> = [
            .shoulderStretch, .shoulderStrength, .shoulderMobility
        ]

        for exercise in shoulderExercises {
            let iconKey = exercise.iconKey

            #expect(shoulderIconKeys.contains(iconKey),
                   "Primary shoulder exercise '\(exercise.name)' has non-shoulder icon: \(iconKey)")
        }
    }

    @Test("Upper back exercises have upper back-related icons")
    func upperBackExercisesHaveUpperBackIcons() {
        let upperBackExercises = allExercises.filter { $0.focusAreas.first == "upper_back" }

        let upperBackIconKeys: Set<IconKey> = [
            .upperBackStretch, .upperBackStrength, .upperBackMobility,
            .breathing // Deep breathing has upper_back as focus
        ]

        for exercise in upperBackExercises {
            let iconKey = exercise.iconKey

            #expect(upperBackIconKeys.contains(iconKey),
                   "Primary upper back exercise '\(exercise.name)' has non-upper-back icon: \(iconKey)")
        }
    }

    @Test("Lower back exercises have lower back-related icons")
    func lowerBackExercisesHaveLowerBackIcons() {
        let lowerBackExercises = allExercises.filter { $0.focusAreas.first == "lower_back" }

        let lowerBackIconKeys: Set<IconKey> = [
            .lowerBackStretch, .lowerBackStrength, .lowerBackMobility
        ]

        for exercise in lowerBackExercises {
            let iconKey = exercise.iconKey

            #expect(lowerBackIconKeys.contains(iconKey),
                   "Primary lower back exercise '\(exercise.name)' has non-lower-back icon: \(iconKey)")
        }
    }

    @Test("Wrist exercises have wrist-related icons")
    func wristExercisesHaveWristIcons() {
        let wristExercises = allExercises.filter { $0.focusAreas.first == "wrists" }

        let wristIconKeys: Set<IconKey> = [
            .wristStretch, .wristMobility
        ]

        for exercise in wristExercises {
            let iconKey = exercise.iconKey

            #expect(wristIconKeys.contains(iconKey),
                   "Primary wrist exercise '\(exercise.name)' has non-wrist icon: \(iconKey)")
        }
    }

    @Test("Hip exercises have hip-related icons")
    func hipExercisesHaveHipIcons() {
        let hipExercises = allExercises.filter { $0.focusAreas.first == "hips" }

        let hipIconKeys: Set<IconKey> = [
            .hipStretch, .hipStrength, .hipMobility
        ]

        for exercise in hipExercises {
            let iconKey = exercise.iconKey

            #expect(hipIconKeys.contains(iconKey),
                   "Primary hip exercise '\(exercise.name)' has non-hip icon: \(iconKey)")
        }
    }

    // MARK: - Specific Exercise Tests

    @Test("Specific exercises have expected icons")
    func specificExercisesHaveExpectedIcons() {
        // Define expected mappings for key exercises
        let expectedMappings: [String: IconKey] = [
            "neck_rolls": .neckMobility,
            "chin_tucks": .neckStrength,
            "neck_side_stretch": .neckStretch,
            "shoulder_shrugs": .shoulderMobility,
            "shoulder_rolls": .shoulderMobility,
            "chest_opener": .shoulderStretch,
            "arm_circles": .shoulderMobility,
            "doorway_stretch": .shoulderStretch,
            "seated_twist": .upperBackMobility,
            "cat_cow_seated": .upperBackMobility,
            "thoracic_extension": .upperBackMobility,
            "pelvic_tilt": .lowerBackMobility,
            "knee_to_chest": .lowerBackStretch,
            "wrist_circles": .wristMobility,
            "wrist_flexor_stretch": .wristStretch,
            "seated_hip_stretch": .hipStretch,
            "deep_breathing": .breathing,
            "eye_palming": .eyeCare,
            "desk_pushups": .shoulderStrength,
            "glute_bridge": .hipStrength
        ]

        for (exerciseId, expectedIcon) in expectedMappings {
            guard let exercise = allExercises.first(where: { $0.id == exerciseId }) else {
                Issue.record("Exercise '\(exerciseId)' not found in catalog")
                continue
            }

            let actualIcon = exercise.iconKey

            #expect(actualIcon == expectedIcon,
                   "Exercise '\(exerciseId)' expected \(expectedIcon) but got \(actualIcon)")
        }
    }

    // MARK: - Catalog Statistics

    @Test("Catalog has reasonable distribution of icons")
    func catalogHasReasonableIconDistribution() {
        var iconCounts: [IconKey: Int] = [:]

        for exercise in allExercises {
            let iconKey = exercise.iconKey
            iconCounts[iconKey, default: 0] += 1
        }

        // Should have multiple icon types used
        #expect(iconCounts.keys.count >= 5, "Should use at least 5 different icon types")

        // No single icon should dominate
        let totalExercises = allExercises.count
        for (iconKey, count) in iconCounts {
            let percentage = Double(count) / Double(totalExercises) * 100
            #expect(percentage < 50, "Icon \(iconKey) is overused at \(percentage)% of exercises")
        }
    }

    // MARK: - Debug Helpers

    @Test("Debug: Print icon distribution")
    func debugPrintIconDistribution() {
        var iconCounts: [IconKey: [String]] = [:]

        for exercise in allExercises {
            let iconKey = exercise.iconKey
            iconCounts[iconKey, default: []].append(exercise.name)
        }

        // This test always passes but prints useful debug info
        print("\n=== Exercise Icon Distribution ===")
        for iconKey in IconKey.allCases {
            if let exercises = iconCounts[iconKey], !exercises.isEmpty {
                print("\n\(iconKey.rawValue) (\(iconKey.sfSymbolName)): \(exercises.count) exercises")
                for name in exercises.prefix(5) {
                    print("  - \(name)")
                }
                if exercises.count > 5 {
                    print("  ... and \(exercises.count - 5) more")
                }
            }
        }
        print("\n=================================")
    }
}
