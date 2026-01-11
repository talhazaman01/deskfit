import SwiftUI

/// Premium selectable card container with Sky Blue theme
struct SelectableCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            content()
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .fill(isSelected ? Color.surfaceSelected : Color.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                .strokeBorder(
                                    isSelected ? Color.appPrimary : Color.borderSubtle,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
                .shadow(
                    color: isSelected ? Color.appPrimary.opacity(0.15) : Theme.Shadow.card,
                    radius: Theme.Shadow.cardRadius,
                    x: Theme.Shadow.cardX,
                    y: Theme.Shadow.cardY
                )
        }
        .buttonStyle(.plain)
        .animation(Theme.Animation.quick, value: isSelected)
    }
}

/// Premium selectable row with icon and checkbox
struct SelectableRow: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        SelectableCard(isSelected: isSelected, action: action) {
            HStack(spacing: Theme.Spacing.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Theme.IconSize.large))
                        .foregroundStyle(isSelected ? .appPrimary : .textSecondary)
                        .frame(width: 32)
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .appPrimary : .textTertiary)
                    .font(.system(size: Theme.IconSize.large))
            }
        }
    }
}

/// Premium multi-selectable row with checkbox
struct MultiSelectableRow: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Theme.IconSize.medium))
                        .foregroundStyle(isSelected ? .appPrimary : .textSecondary)
                        .frame(width: 28)
                }

                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundStyle(.textPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? .appPrimary : .textTertiary)
                    .font(.system(size: Theme.IconSize.medium))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? Color.surfaceSelected : Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.medium)
                            .strokeBorder(
                                isSelected ? Color.appPrimary : Color.borderSubtle,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: Theme.Shadow.card,
                radius: Theme.Shadow.cardRadius,
                x: Theme.Shadow.cardX,
                y: Theme.Shadow.cardY
            )
        }
        .buttonStyle(.plain)
        .animation(Theme.Animation.quick, value: isSelected)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        SelectableRow(
            title: "Move More",
            subtitle: "Get more movement into your day",
            icon: "figure.run",
            isSelected: true
        ) {}

        SelectableRow(
            title: "Build a Habit",
            subtitle: "Create a consistent routine",
            icon: "calendar",
            isSelected: false
        ) {}

        MultiSelectableRow(
            title: "Neck",
            icon: "figure.stand",
            isSelected: true
        ) {}
    }
    .padding()
    .background(Color.background)
}
