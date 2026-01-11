import SwiftUI

/// Timer display with circular progress and Montserrat typography
struct TimerView: View {
    let timeRemaining: Int
    let totalTime: Int

    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }

    var body: some View {
        ZStack {
            ProgressRing(progress: progress, lineWidth: 12, size: 150)

            Text("\(timeRemaining)")
                .font(Theme.Typography.stat)
                .monospacedDigit()
                .foregroundStyle(.textPrimary)
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.xl) {
        TimerView(timeRemaining: 15, totalTime: 30)
        TimerView(timeRemaining: 45, totalTime: 60)
    }
    .padding()
    .background(Color.background)
}
