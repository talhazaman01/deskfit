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

            Text(exercise.cue)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.screenHorizontal)

            // Contraindication warning
            if !exercise.contraindication.isEmpty {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.warning)
                        .font(Theme.Typography.caption)
                    Text(exercise.contraindication)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.small)
                        .fill(Color.warning.opacity(0.1))
                )
            }
        }
    }
}
