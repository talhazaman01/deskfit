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

/// Time option card with clear selection indicator
/// Features: border and background tint when selected
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
            ZStack(alignment: .top) {
                VStack(spacing: Theme.Spacing.xs) {
                    Text(label)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.textPrimary)

                    Text(description)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 90)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .fill(isSelected ? Color.cardSelected : Color.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .strokeBorder(
                            isSelected ? Color.borderSelected : Color.borderDefault,
                            lineWidth: isSelected ? 2 : 1
                        )
                )

                // Selection indicator at top
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.appTeal)
                            .frame(width: 22, height: 22)

                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.textOnAccent)
                    }
                    .offset(y: -11)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview("Time Preference") {
    TimePreferenceView(selectedTime: .constant(5))
        .deskFitScreenBackground()
}

#Preview("Time Cards Only") {
    HStack(spacing: 12) {
        TimeCard(label: "2 min", description: "Quick", isSelected: false) {}
        TimeCard(label: "5 min", description: "Balanced", isSelected: true) {}
        TimeCard(label: "10 min", description: "Thorough", isSelected: false) {}
    }
    .padding()
    .deskFitScreenBackground()
}
