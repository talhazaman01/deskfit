import SwiftUI

struct ReminderSetupView: View {
    @Binding var selectedFrequency: ReminderFrequency

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundStyle(.brandPrimary)

            Text("Stay on track with reminders")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("We'll gently nudge you when it's time for a break")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                ForEach(ReminderFrequency.allCases) { frequency in
                    ReminderOptionRow(
                        frequency: frequency,
                        isSelected: selectedFrequency == frequency
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFrequency = frequency
                            HapticsService.shared.light()
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct ReminderOptionRow: View {
    let frequency: ReminderFrequency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(frequency.displayName)
                    .font(.body)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.brandPrimary)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryBackground)
            )
        }
        .buttonStyle(.plain)
    }
}
