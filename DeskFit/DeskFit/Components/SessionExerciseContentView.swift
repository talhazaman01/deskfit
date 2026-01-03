import SwiftUI

/// A scrollable content view for displaying exercise information during sessions.
/// Shows the exercise illustration, name, instructions, and safety disclaimer.
/// Scrolls when content exceeds available space, ensuring all text is always readable.
/// Used by both SessionPlayerView and StarterResetView for consistent behavior.
struct SessionExerciseContentView: View {
    let exercise: Exercise

    /// Optional size variant for slightly smaller display (e.g., onboarding)
    var isCompact: Bool = false

    private var iconSize: CGFloat { isCompact ? 180 : 200 }
    private var iconFontSize: CGFloat { isCompact ? 70 : 80 }
    private var titleFontSize: CGFloat { 22 }
    private var cueFontSize: CGFloat { isCompact ? 18 : 20 }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Theme.Spacing.xl) {
                // Exercise illustration
                exerciseIllustration

                // Exercise name
                exerciseName

                // Exercise instruction/cue - FULL TEXT, NO TRUNCATION
                exerciseInstruction

                // Safety disclaimer - FULL TEXT, NO TRUNCATION
                if !exercise.contraindication.isEmpty {
                    safetyDisclaimer
                }
            }
            .padding(.vertical, Theme.Spacing.md)
        }
    }

    // MARK: - Subviews

    private var exerciseIllustration: some View {
        ZStack {
            Circle()
                .fill(Color.appTeal.opacity(0.1))
                .frame(width: iconSize, height: iconSize)

            Image(systemName: "figure.flexibility")
                .font(.system(size: iconFontSize))
                .foregroundStyle(.appTeal)
        }
    }

    private var exerciseName: some View {
        Text(exercise.name)
            .font(.system(size: titleFontSize, weight: .bold))
            .foregroundStyle(.textPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .minimumScaleFactor(0.9)
            .accessibilityIdentifier("ExerciseName")
    }

    private var exerciseInstruction: some View {
        Text(exercise.cue)
            .font(.system(size: cueFontSize, weight: .regular))
            .foregroundStyle(.textSecondary)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .accessibilityIdentifier("ExerciseDescription")
    }

    private var safetyDisclaimer: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.warning)
                .font(.system(size: 15, weight: .medium))
                .padding(.top, 3)

            // Improved typography: slightly larger font, comfortable line spacing
            Text(exercise.contraindication)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(3)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.warning.opacity(0.08))
        )
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .accessibilityIdentifier("SafetyDisclaimer")
    }
}

// MARK: - Previews

#Preview("Short text - iPhone SE") {
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
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Long text - iPhone SE") {
    SessionExerciseContentView(
        exercise: Exercise(
            id: "preview-long-se",
            name: "Deep Neck Stretch with Shoulder Release",
            description: "Comprehensive neck and shoulder stretch",
            cue: "Begin by sitting tall with your feet flat on the floor. Slowly tilt your head to the right, bringing your right ear toward your right shoulder. Use your right hand to gently apply pressure on the left side of your head for a deeper stretch. Hold this position for 15-20 seconds while breathing deeply. You should feel a comfortable stretch along the left side of your neck. Return to center slowly, then repeat on the opposite side. Keep your shoulders relaxed and down throughout the movement.",
            durationSeconds: 60,
            focusAreas: ["neck", "shoulders"],
            difficulty: "medium",
            imageAsset: "",
            animationAsset: nil,
            contraindication: "Stop immediately if you experience dizziness, sharp pain, or numbness in your arms or fingers. This exercise is not recommended for individuals with cervical spine injuries, herniated discs, recent neck surgery, or those experiencing acute neck pain. If you have any history of stroke or vertebral artery issues, please consult your healthcare provider before attempting this stretch."
        )
    )
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Long text - iPhone 15 Pro") {
    SessionExerciseContentView(
        exercise: Exercise(
            id: "preview-long-15pro",
            name: "Deep Neck Stretch with Shoulder Release",
            description: "Comprehensive neck and shoulder stretch",
            cue: "Begin by sitting tall with your feet flat on the floor. Slowly tilt your head to the right, bringing your right ear toward your right shoulder. Use your right hand to gently apply pressure on the left side of your head for a deeper stretch. Hold this position for 15-20 seconds while breathing deeply. You should feel a comfortable stretch along the left side of your neck. Return to center slowly, then repeat on the opposite side. Keep your shoulders relaxed and down throughout the movement.",
            durationSeconds: 60,
            focusAreas: ["neck", "shoulders"],
            difficulty: "medium",
            imageAsset: "",
            animationAsset: nil,
            contraindication: "Stop immediately if you experience dizziness, sharp pain, or numbness in your arms or fingers. This exercise is not recommended for individuals with cervical spine injuries, herniated discs, recent neck surgery, or those experiencing acute neck pain. If you have any history of stroke or vertebral artery issues, please consult your healthcare provider before attempting this stretch."
        )
    )
    .previewDevice("iPhone 15 Pro")
}

#Preview("Long text - iPhone 15 Pro Max") {
    SessionExerciseContentView(
        exercise: Exercise(
            id: "preview-long-15promax",
            name: "Deep Neck Stretch with Shoulder Release",
            description: "Comprehensive neck and shoulder stretch",
            cue: "Begin by sitting tall with your feet flat on the floor. Slowly tilt your head to the right, bringing your right ear toward your right shoulder. Use your right hand to gently apply pressure on the left side of your head for a deeper stretch. Hold this position for 15-20 seconds while breathing deeply. You should feel a comfortable stretch along the left side of your neck. Return to center slowly, then repeat on the opposite side. Keep your shoulders relaxed and down throughout the movement.",
            durationSeconds: 60,
            focusAreas: ["neck", "shoulders"],
            difficulty: "medium",
            imageAsset: "",
            animationAsset: nil,
            contraindication: "Stop immediately if you experience dizziness, sharp pain, or numbness in your arms or fingers. This exercise is not recommended for individuals with cervical spine injuries, herniated discs, recent neck surgery, or those experiencing acute neck pain. If you have any history of stroke or vertebral artery issues, please consult your healthcare provider before attempting this stretch."
        )
    )
    .previewDevice("iPhone 15 Pro Max")
}

#Preview("Compact variant - Onboarding") {
    SessionExerciseContentView(
        exercise: Exercise(
            id: "preview-compact",
            name: "Shoulder Shrug",
            description: "Quick shoulder relief",
            cue: "Raise both shoulders toward your ears, hold for 3 seconds, then release completely. Repeat 5 times. Focus on the release phase, letting go of all tension.",
            durationSeconds: 20,
            focusAreas: ["shoulders"],
            difficulty: "easy",
            imageAsset: "",
            animationAsset: nil,
            contraindication: "Avoid if you have shoulder injuries or recent surgery."
        ),
        isCompact: true
    )
}

#Preview("Very long text - Stress test") {
    SessionExerciseContentView(
        exercise: Exercise(
            id: "preview-stress",
            name: "Complete Upper Body Reset with Guided Breathing",
            description: "Full upper body stretch sequence",
            cue: "This comprehensive stretch begins with finding a comfortable seated position. Place both feet flat on the floor, hip-width apart. Sit tall, imagining a string pulling the crown of your head toward the ceiling. Take three deep breaths to center yourself. First, we'll work on the neck: slowly drop your chin toward your chest, feeling the stretch along the back of your neck. Hold for 10 seconds. Then, look up toward the ceiling, opening the front of your throat. Hold for 10 seconds. Return to neutral. Next, tilt your head to the right, then left, holding each side for 10 seconds. Now for the shoulders: roll them forward in big circles 5 times, then backward 5 times. Finally, interlace your fingers behind your back, squeeze your shoulder blades together, and lift your arms slightly while opening your chest. Hold this position for 15 seconds while breathing deeply.",
            durationSeconds: 120,
            focusAreas: ["neck", "shoulders", "back"],
            difficulty: "medium",
            imageAsset: "",
            animationAsset: nil,
            contraindication: "This exercise involves multiple movements and should be approached with caution if you have any existing neck, shoulder, or back conditions. Stop immediately if you experience any sharp pain, dizziness, numbness, or tingling. Not recommended for individuals with cervical spine injuries, herniated discs, rotator cuff tears, frozen shoulder, or recent surgery in the neck, shoulder, or upper back area. If you have a history of stroke, vertebral artery dissection, or any cardiovascular conditions, please consult your healthcare provider before attempting. Pregnant individuals should modify by avoiding deep neck extension (looking up). If you wear glasses or contacts, remove them before doing neck stretches to prevent strain."
        )
    )
}
