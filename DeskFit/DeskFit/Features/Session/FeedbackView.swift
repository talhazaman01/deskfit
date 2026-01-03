import SwiftUI

struct FeedbackView: View {
    let onSelect: (SessionFeedback) -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            ForEach(SessionFeedback.allCases, id: \.self) { feedback in
                FeedbackButton(feedback: feedback) {
                    HapticsService.shared.light()
                    onSelect(feedback)
                }
            }
        }
    }
}

struct FeedbackButton: View {
    let feedback: SessionFeedback
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: feedback.icon)
                    .font(.title2)
                    .foregroundStyle(.textPrimary)
                Text(feedback.displayName)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}
