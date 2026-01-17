import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 100

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.progressRingTrack, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppTheme.progressRingFill,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(Theme.Animation.standard, value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 20) {
        ProgressRing(progress: 0.25)
        ProgressRing(progress: 0.5)
        ProgressRing(progress: 0.75)
    }
}
