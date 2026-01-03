import SwiftUI

struct TimePreferenceView: View {
    @Binding var selectedTime: Int

    private let options = [
        (value: 2, label: "2 min", description: "Quick resets"),
        (value: 5, label: "5 min", description: "Balanced"),
        (value: 10, label: "10 min", description: "Thorough")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("How much time per break?")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(.textPrimary)

                Text("You'll get 3 breaks throughout the day.")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.xxl)

            Spacer()

            // Time options
            HStack(spacing: Theme.Spacing.md) {
                ForEach(options, id: \.value) { option in
                    TimeCard(
                        label: option.label,
                        description: option.description,
                        isSelected: selectedTime == option.value
                    ) {
                        withAnimation(Theme.Animation.spring) {
                            selectedTime = option.value
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            Spacer()
            Spacer()
        }
    }
}

struct TimeCard: View {
    let label: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            VStack(spacing: Theme.Spacing.xs) {
                Text(label)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(isSelected ? .textOnDark : .textPrimary)

                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(isSelected ? .textOnDark.opacity(0.7) : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? Color.cardSelected : Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimePreferenceView(selectedTime: .constant(5))
}
