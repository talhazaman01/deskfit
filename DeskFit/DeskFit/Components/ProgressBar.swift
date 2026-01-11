import SwiftUI

/// Cal AI style thin progress bar
struct ProgressBar: View {
    let progress: Double  // 0.0 to 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.progressBackground)
                    .frame(height: Theme.Height.progressBar)

                // Fill
                Rectangle()
                    .fill(Color.progressFill)
                    .frame(width: geometry.size.width * progress, height: Theme.Height.progressBar)
            }
        }
        .frame(height: Theme.Height.progressBar)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.2)
        ProgressBar(progress: 0.5)
        ProgressBar(progress: 0.8)
    }
    .padding()
}
