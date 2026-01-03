import SwiftUI

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
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.textPrimary)
        }
    }
}

#Preview {
    TimerView(timeRemaining: 15, totalTime: 30)
}
