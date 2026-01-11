import SwiftUI

/// Premium option card with Sky Blue selected state
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
                        .font(Theme.Typography.bodyMedium)
                        .foregroundStyle(isSelected ? .textOnPrimary : .appPrimary)
                        .frame(width: 24)
                }

                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Typography.option)
                        .foregroundStyle(isSelected ? .textOnPrimary : .textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Theme.Typography.optionDescription)
                            .foregroundStyle(isSelected ? Color.textOnPrimary.opacity(0.8) : .textSecondary)
                    }
                }

                Spacer()

                // Checkmark for selected state
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(Theme.Typography.bodyMedium)
                        .foregroundStyle(.textOnPrimary)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .frame(height: subtitle != nil ? Theme.Height.optionCardWithDescription : Theme.Height.optionCard)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? Color.appPrimary : Color.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .strokeBorder(isSelected ? Color.clear : Color.borderSubtle, lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color.appPrimary.opacity(0.2) : Theme.Shadow.card,
                radius: isSelected ? 8 : Theme.Shadow.cardRadius,
                x: Theme.Shadow.cardX,
                y: isSelected ? 4 : Theme.Shadow.cardY
            )
        }
        .buttonStyle(.plain)
        .animation(Theme.Animation.quick, value: isSelected)
    }
}

/// Multi-select chip style (2-column grid) with Sky Blue theme
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
                        .font(.system(size: Theme.IconSize.large))
                        .foregroundStyle(isSelected ? .textOnPrimary : .appPrimary)
                }

                Text(title)
                    .font(Theme.Typography.option)
                    .foregroundStyle(isSelected ? .textOnPrimary : .textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? Color.appPrimary : Color.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .strokeBorder(isSelected ? Color.clear : Color.borderSubtle, lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color.appPrimary.opacity(0.2) : Theme.Shadow.card,
                radius: isSelected ? 8 : Theme.Shadow.cardRadius,
                x: Theme.Shadow.cardX,
                y: isSelected ? 4 : Theme.Shadow.cardY
            )
        }
        .buttonStyle(.plain)
        .animation(Theme.Animation.quick, value: isSelected)
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
    .background(Color.background)
}
