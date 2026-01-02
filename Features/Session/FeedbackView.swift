import SwiftUI

struct FeedbackView: View {
    let onSelect: (SessionFeedback) -> Void

    var body: some View {
        HStack(spacing: 16) {
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
            VStack(spacing: 8) {
                Image(systemName: feedback.icon)
                    .font(.title2)
                Text(feedback.displayName)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryBackground)
            )
        }
        .buttonStyle(.plain)
    }
}
