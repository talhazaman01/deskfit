import SwiftUI

struct ReminderSetupView: View {
    @Binding var selectedFrequency: ReminderFrequency

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("How often should we remind you?")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(.textPrimary)

                Text("We'll gently nudge you when it's time for a break.")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.xxl)

            Spacer()

            // Frequency options
            VStack(spacing: Theme.Spacing.md) {
                ForEach(ReminderFrequency.allCases) { frequency in
                    OptionCard(
                        title: frequency.displayName,
                        icon: iconFor(frequency),
                        isSelected: selectedFrequency == frequency
                    ) {
                        withAnimation(Theme.Animation.spring) {
                            selectedFrequency = frequency
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            Spacer()
            Spacer()
        }
    }

    private func iconFor(_ frequency: ReminderFrequency) -> String {
        switch frequency {
        case .hourly: return "clock"
        case .every2Hours: return "clock.badge.checkmark"
        case .threeDaily: return "calendar"
        case .off: return "bell.slash"
        }
    }
}

#Preview {
    ReminderSetupView(selectedFrequency: .constant(.every2Hours))
}
