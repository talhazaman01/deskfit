import SwiftUI

/// Scrollable exercise content view with Sky Blue theme
struct SessionExerciseContentView: View {
    let exercise: Exercise
    var isCompact: Bool = false

    private var iconSize: CGFloat { isCompact ? 180 : 200 }
    private var iconFontSize: CGFloat { isCompact ? 70 : 80 }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Theme.Spacing.xl) {
                // Exercise illustration
                exerciseIllustration

                // Exercise name
                exerciseName

                // Exercise instruction
                exerciseInstruction
            }
            .padding(.vertical, Theme.Spacing.md)
        }
    }

    // MARK: - Subviews

    private var exerciseIllustration: some View {
        ZStack {
            Circle()
                .fill(Color.appPrimary.opacity(0.1))
                .frame(width: iconSize, height: iconSize)

            Image(systemName: exercise.iconName)
                .font(.system(size: iconFontSize))
                .foregroundStyle(.appPrimary)
                .accessibilityLabel(exercise.iconAccessibilityLabel)
        }
    }

    private var exerciseName: some View {
        Text(exercise.name)
            .font(Theme.Typography.title2)
            .foregroundStyle(.textPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .minimumScaleFactor(0.9)
            .accessibilityIdentifier("ExerciseName")
    }

    private var exerciseInstruction: some View {
        Text(exercise.cue)
            .font(Theme.Typography.body)
            .foregroundStyle(.textSecondary)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .accessibilityIdentifier("ExerciseDescription")
    }
}

// MARK: - Previews

#Preview("Short text") {
    SessionExerciseContentView(
        exercise: Exercise(
            id: "preview-short",
            name: "Neck Roll",
            description: "Simple neck stretch",
            cue: "Gently roll your head in a circle.",
            durationSeconds: 30,
            focusAreas: ["neck"],
            difficulty: "easy",
            imageAsset: "",
            animationAsset: nil,
            contraindication: "Stop if dizzy."
        )
    )
    .background(Color.background)
}

#Preview("Long text") {
    SessionExerciseContentView(
        exercise: Exercise(
            id: "preview-long",
            name: "Deep Neck Stretch with Shoulder Release",
            description: "Comprehensive neck and shoulder stretch",
            cue: "Begin by sitting tall with your feet flat on the floor. Slowly tilt your head to the right, bringing your right ear toward your right shoulder. Use your right hand to gently apply pressure on the left side of your head for a deeper stretch. Hold this position for 15-20 seconds while breathing deeply. You should feel a comfortable stretch along the left side of your neck. Return to center slowly, then repeat on the opposite side. Keep your shoulders relaxed and down throughout the movement.",
            durationSeconds: 60,
            focusAreas: ["neck", "shoulders"],
            difficulty: "medium",
            imageAsset: "",
            animationAsset: nil,
            contraindication: "Stop if dizzy or in pain."
        )
    )
    .background(Color.background)
}
