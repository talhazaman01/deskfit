import SwiftUI

/// Premium circular progress view with Sky Blue theme
struct CircularProgressView: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 100
    var backgroundColor: Color = Color.progressBackground
    var foregroundColor: Color = .appPrimary

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(Theme.Animation.standard, value: progress)
        }
        .frame(width: size, height: size)
    }
}

/// Timer display with circular progress
struct TimerCircleView: View {
    let totalSeconds: Int
    let remainingSeconds: Int
    var size: CGFloat = 200

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            CircularProgressView(
                progress: progress,
                lineWidth: 12,
                size: size
            )

            VStack(spacing: Theme.Spacing.xs) {
                Text(timeString)
                    .font(Theme.Typography.statMedium)
                    .monospacedDigit()
                    .foregroundStyle(.textPrimary)

                Text("remaining")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

/// Streak badge with flame icon
struct StreakBadge: View {
    let count: Int
    var showFlame: Bool = true

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            if showFlame {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.streakFlame)
            }
            Text("\(count)")
                .font(Theme.Typography.subbodyMedium)
                .foregroundStyle(.textPrimary)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(
            Capsule()
                .fill(Color.streakFlame.opacity(0.15))
        )
    }
}

/// Score ring for displaying daily/weekly score
struct ScoreRing: View {
    let score: Int
    let maxScore: Int
    var size: CGFloat = 120
    var lineWidth: CGFloat = 10

    private var progress: Double {
        guard maxScore > 0 else { return 0 }
        return Double(score) / Double(maxScore)
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.progressBackground, lineWidth: lineWidth)

            // Progress arc with gradient
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.tertiary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(Theme.Animation.spring, value: progress)

            // Center content
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(Theme.Typography.statMedium)
                    .foregroundStyle(.textPrimary)

                Text("/ \(maxScore)")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.xxl) {
        CircularProgressView(progress: 0.7)

        TimerCircleView(totalSeconds: 120, remainingSeconds: 45)

        StreakBadge(count: 7)

        ScoreRing(score: 75, maxScore: 100)
    }
    .padding()
    .background(Color.background)
}
