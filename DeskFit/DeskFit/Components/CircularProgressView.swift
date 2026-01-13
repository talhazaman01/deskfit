import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 100
    var backgroundColor: Color = AppTheme.progressRingTrack
    var foregroundColor: Color = AppTheme.progressRingFill

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
                .animation(.easeOut(duration: 0.3), value: progress)
        }
        .frame(width: size, height: size)
    }
}

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

            VStack(spacing: 4) {
                Text(timeString)
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text("remaining")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

struct StreakBadge: View {
    let count: Int
    var showFlame: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            if showFlame {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color.streakFlame)
            }
            Text("\(count)")
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.streakFlame.opacity(0.15))
        )
    }
}

#Preview {
    VStack(spacing: 32) {
        CircularProgressView(progress: 0.7)

        TimerCircleView(totalSeconds: 120, remainingSeconds: 45)

        StreakBadge(count: 7)
    }
    .padding()
}
