import SwiftUI

struct ExerciseDisplayView: View {
    let exercise: Exercise
    let timeRemaining: Int

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // TODO: Replace with actual exercise image/animation
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.1))
                    .frame(width: 200, height: 200)

                Image(systemName: "figure.flexibility")
                    .font(.system(size: 80))
                    .foregroundStyle(.appTeal)
            }

            Text(exercise.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("ExerciseName")

            // Exercise description/cue with expandable text (3 lines max)
            ExpandableTextView(
                text: exercise.cue,
                lineLimit: 3,
                font: .system(size: 20, weight: .regular),
                foregroundColor: .textSecondary,
                moreButtonColor: .appTeal
            )
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .accessibilityIdentifier("ExerciseDescription")

            // Contraindication/safety warning with expandable text (2 lines max)
            if !exercise.contraindication.isEmpty {
                SafetyDisclaimerView(text: exercise.contraindication)
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
            }
        }
    }
}

// MARK: - Safety Disclaimer View

/// Displays safety/contraindication warnings with expandable text behavior.
/// Limited to 2 lines by default with a "More" button for longer content.
private struct SafetyDisclaimerView: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.warning)
                .font(Theme.Typography.caption)
                .padding(.top, 2)

            ExpandableTextView(
                text: text,
                lineLimit: 2,
                font: Theme.Typography.caption,
                foregroundColor: .textSecondary,
                moreButtonColor: .warning
            )
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Color.warning.opacity(0.1))
        )
        .accessibilityIdentifier("SafetyDisclaimer")
    }
}
