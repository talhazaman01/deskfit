import SwiftUI

struct ExerciseDisplayView: View {
    let exercise: Exercise
    let timeRemaining: Int

    var body: some View {
        VStack(spacing: 24) {
            // TODO: Replace with actual exercise image/animation
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.1))
                    .frame(width: 200, height: 200)

                Image(systemName: "figure.flexibility")
                    .font(.system(size: 80))
                    .foregroundStyle(.brandPrimary)
            }

            Text(exercise.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(exercise.cue)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Contraindication warning
            if !exercise.contraindication.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text(exercise.contraindication)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
    }
}
