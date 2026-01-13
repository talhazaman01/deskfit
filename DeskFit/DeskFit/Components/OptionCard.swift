import SwiftUI

/// Selectable option card with clear visual selection state
/// Features: border, background tint, and checkmark indicator when selected
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
                        .foregroundStyle(isSelected ? AppTheme.selectionCheck : AppTheme.textPrimary)
                        .frame(width: 24)
                }

                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Typography.option)
                        .foregroundStyle(AppTheme.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Theme.Typography.optionDescription)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Spacer()

                // Checkmark indicator for selected state
                if isSelected {
                    SelectionCheckmark()
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .frame(height: subtitle != nil ? Theme.Height.optionCardWithDescription : Theme.Height.optionCard)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? AppTheme.selectionFill : AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .strokeBorder(
                        isSelected ? AppTheme.selectionStroke : AppTheme.strokeSubtle,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

/// Multi-select chip style (2-column grid) with clear selection indicator
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
            ZStack(alignment: .topTrailing) {
                VStack(spacing: Theme.Spacing.sm) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundStyle(isSelected ? AppTheme.selectionCheck : AppTheme.accent.opacity(0.7))
                    }

                    Text(title)
                        .font(Theme.Typography.option)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .fill(isSelected ? AppTheme.selectionFill : AppTheme.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .strokeBorder(
                            isSelected ? AppTheme.selectionStroke : AppTheme.strokeSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )

                // Selection checkmark badge
                if isSelected {
                    SelectionCheckmark(size: 20, iconSize: 10)
                        .offset(x: -8, y: 8)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview("Selection States") {
    ScrollView {
        VStack(spacing: 16) {
            Text("Option Cards")
                .font(Theme.Typography.headline)
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            OptionCard(title: "Unselected Option", isSelected: false) {}
            OptionCard(title: "Selected Option", isSelected: true) {}
            OptionCard(
                title: "With Subtitle",
                subtitle: "Description text here",
                icon: "star.fill",
                isSelected: false
            ) {}
            OptionCard(
                title: "Selected with All",
                subtitle: "This one is selected",
                icon: "checkmark.circle.fill",
                isSelected: true
            ) {}

            Text("Selection Chips")
                .font(Theme.Typography.headline)
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SelectionChip(title: "Selected", icon: "figure.stand", isSelected: true) {}
                SelectionChip(title: "Unselected", icon: "figure.arms.open", isSelected: false) {}
            }
        }
        .padding()
    }
    .deskFitScreenBackground()
}

#Preview("Dark Mode") {
    VStack(spacing: 12) {
        OptionCard(title: "Dark Unselected", isSelected: false) {}
        OptionCard(title: "Dark Selected", isSelected: true) {}
    }
    .padding()
    .deskFitScreenBackground()
    .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    VStack(spacing: 12) {
        OptionCard(title: "Light Unselected", isSelected: false) {}
        OptionCard(title: "Light Selected", isSelected: true) {}
    }
    .padding()
    .deskFitScreenBackground()
    .preferredColorScheme(.light)
}
