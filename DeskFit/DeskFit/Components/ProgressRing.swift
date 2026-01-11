import SwiftUI

/// Progress ring with Sky Blue gradient
struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 100
    var useGradient: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.progressBackground, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    useGradient ?
                        AnyShapeStyle(LinearGradient(
                            colors: [Color.appPrimary, Color.tertiary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )) :
                        AnyShapeStyle(Color.appPrimary),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(Theme.Animation.standard, value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.xl) {
        ProgressRing(progress: 0.25)
        ProgressRing(progress: 0.5)
        ProgressRing(progress: 0.75, useGradient: false)
    }
    .padding()
    .background(Color.background)
}
