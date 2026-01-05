import SwiftUI

/// Displays exercise information including illustration, name, and instructions.
/// All text is shown in full without truncation - no "More/Less" buttons.
/// This view is designed to be placed inside a ScrollView in the parent view
/// to handle overflow on smaller devices.
struct ExerciseDisplayView: View {
    let exercise: Exercise
    let timeRemaining: Int

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Exercise illustration
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.1))
                    .frame(width: 200, height: 200)

                Image(systemName: "figure.flexibility")
                    .font(.system(size: 80))
                    .foregroundStyle(.appTeal)
            }

            // Exercise name - full text, no truncation
            Text(exercise.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.9)
                .accessibilityIdentifier("ExerciseName")

            // Exercise instruction/cue - FULL TEXT, NO TRUNCATION
            Text(exercise.cue)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .accessibilityIdentifier("ExerciseDescription")
        }
    }
}

// MARK: - Previews

#Preview("Short text") {
    ScrollView {
        ExerciseDisplayView(
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
            ),
            timeRemaining: 30
        )
    }
}

#Preview("Long text - iPhone SE") {
    ScrollView {
        ExerciseDisplayView(
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
            ),
            timeRemaining: 60
        )
    }
}

#Preview("Long text - iPhone 15 Pro") {
    ScrollView {
        ExerciseDisplayView(
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
            ),
            timeRemaining: 60
        )
    }
}

#Preview("Long text - iPhone 15 Pro Max") {
    ScrollView {
        ExerciseDisplayView(
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
            ),
            timeRemaining: 60
        )
    }
}

#Preview("Very long text - Stress test") {
    ScrollView {
        ExerciseDisplayView(
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
            ),
            timeRemaining: 120
        )
    }
}
