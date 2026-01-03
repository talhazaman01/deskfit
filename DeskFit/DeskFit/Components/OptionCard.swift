import SwiftUI

/// Cal AI style option card - black fill when selected, gray when not
struct OptionCard: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            HStack(spacing: Theme.Spacing.md) {
                // Leading icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isSelected ? .textOnDark : .textPrimary)
                        .frame(width: 24)
                }

                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Typography.option)
                        .foregroundStyle(isSelected ? .textOnDark : .textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Theme.Typography.optionDescription)
                            .foregroundStyle(isSelected ? .textOnDark.opacity(0.7) : .textSecondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .frame(height: subtitle != nil ? Theme.Height.optionCardWithDescription : Theme.Height.optionCard)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? Color.cardSelected : Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Multi-select chip style (2-column grid)
struct SelectionChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            VStack(spacing: Theme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(isSelected ? .textOnDark : .appTeal)
                }

                Text(title)
                    .font(Theme.Typography.option)
                    .foregroundStyle(isSelected ? .textOnDark : .textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? Color.cardSelected : Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        OptionCard(title: "Male", isSelected: false) {}
        OptionCard(title: "Female", isSelected: true) {}
        OptionCard(
            title: "0-2",
            subtitle: "Workouts now and then",
            icon: "circle.fill",
            isSelected: false
        ) {}

        HStack(spacing: 12) {
            SelectionChip(title: "Neck", icon: "figure.stand", isSelected: true) {}
            SelectionChip(title: "Shoulders", icon: "figure.arms.open", isSelected: false) {}
        }
    }
    .padding()
}
