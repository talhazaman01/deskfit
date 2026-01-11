import SwiftUI

struct SessionCompleteView: View {
    let session: PlannedSession
    let onFeedback: (SessionFeedback?) -> Void

    @State private var showFeedback = true

    var body: some View {
        VStack(spacing: Theme.Spacing.xxl) {
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
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(.textPrimary)

            Text("You completed \(session.durationSeconds.formattedMinutes) of movement")
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)

            if showFeedback {
                VStack(spacing: Theme.Spacing.lg) {
                    Text("How was this session?")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    FeedbackView { feedback in
                        onFeedback(feedback)
                    }
                }
                .padding(.top, Theme.Spacing.xl)
            }

            Spacer()

            PrimaryButton(title: "Done") {
                onFeedback(nil)
            }
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
    }
}
