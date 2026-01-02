import SwiftUI

struct SessionCompleteView: View {
    let session: PlannedSession
    let onFeedback: (SessionFeedback?) -> Void

    @State private var showFeedback = true

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.success.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.success)
            }

            Text("Great job!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("You completed \(session.durationSeconds.formattedMinutes) of movement")
                .font(.body)
                .foregroundStyle(.secondary)

            if showFeedback {
                VStack(spacing: 16) {
                    Text("How was this session?")
                        .font(.headline)

                    FeedbackView { feedback in
                        onFeedback(feedback)
                    }
                }
                .padding(.top, 24)
            }

            Spacer()

            PrimaryButton(title: "Done") {
                onFeedback(nil)
            }
            .padding(.bottom, 32)
        }
        .padding()
    }
}
