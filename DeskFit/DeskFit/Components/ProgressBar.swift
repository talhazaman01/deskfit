import SwiftUI

/// Premium progress bar with Sky Blue theme
struct ProgressBar: View {
    let progress: Double  // 0.0 to 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.progressBackground)
                    .frame(height: Theme.Height.progressBar)

                // Fill with primary color
                Rectangle()
                    .fill(Color.progressFill)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1), height: Theme.Height.progressBar)
                    .animation(Theme.Animation.standard, value: progress)
            }
        }
        .frame(height: Theme.Height.progressBar)
        .clipShape(Capsule())
    }
}

/// Segmented progress indicator for multi-step flows
struct SegmentedProgressBar: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step < currentStep ? Color.appPrimary : Color.progressBackground)
                    .frame(height: Theme.Height.progressBar)
                    .animation(Theme.Animation.quick, value: currentStep)
            }
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.xl) {
        ProgressBar(progress: 0.2)
        ProgressBar(progress: 0.5)
        ProgressBar(progress: 0.8)

        SegmentedProgressBar(totalSteps: 5, currentStep: 3)
    }
    .padding()
    .background(Color.background)
}
