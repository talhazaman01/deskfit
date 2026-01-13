import SwiftUI

/// Generic selectable card container with clear selection styling
struct SelectableCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            content()
                .padding()
                .frame(maxWidth: .infinity)
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
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

/// Row-style selectable item with icon and checkmark indicator
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
                        .font(.title2)
                        .foregroundStyle(isSelected ? .appTeal : .textSecondary)
                        .frame(width: 32)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.Typography.option)
                        .foregroundStyle(.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Theme.Typography.optionDescription)
                            .foregroundStyle(.textSecondary)
                    }
                }

                Spacer()

                // Checkmark indicator
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.appTeal)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.textOnAccent)
                    }
                }
            }
        }
    }
}

/// Multi-select row with checkbox-style indicator
struct MultiSelectableRow: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            HStack(spacing: Theme.Spacing.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(isSelected ? .appTeal : .textSecondary)
                        .frame(width: 28)
                }

                Text(title)
                    .font(Theme.Typography.option)
                    .foregroundStyle(.textPrimary)

                Spacer()

                // Checkbox indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(isSelected ? Color.appTeal : Color.borderDefault, lineWidth: isSelected ? 0 : 1.5)
                        .frame(width: 22, height: 22)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isSelected ? Color.appTeal : Color.clear)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.textOnAccent)
                    }
                }
            }
            .padding()
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview("Selectable Components") {
    VStack(spacing: 16) {
        Text("SelectableRow")
            .font(Theme.Typography.headline)
            .foregroundStyle(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)

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

        Text("MultiSelectableRow")
            .font(Theme.Typography.headline)
            .foregroundStyle(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)

        MultiSelectableRow(
            title: "Neck",
            icon: "figure.stand",
            isSelected: true
        ) {}

        MultiSelectableRow(
            title: "Shoulders",
            icon: "figure.arms.open",
            isSelected: false
        ) {}
    }
    .padding()
    .deskFitScreenBackground()
}
