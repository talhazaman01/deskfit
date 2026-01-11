import SwiftUI

/// Focus area selection chip for onboarding with Sky Blue theme
struct FocusAreaChip: View {
    let area: FocusArea
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: area.icon)
                    .font(.system(size: Theme.IconSize.extraLarge))
                    .foregroundStyle(isSelected ? .textOnPrimary : .appPrimary)

                Text(area.displayName)
                    .font(Theme.Typography.option)
                    .foregroundStyle(isSelected ? .textOnPrimary : .textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
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
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
        FocusAreaChip(area: .neck, isSelected: true) {}
        FocusAreaChip(area: .shoulders, isSelected: false) {}
        FocusAreaChip(area: .lowerBack, isSelected: false) {}
        FocusAreaChip(area: .wrists, isSelected: true) {}
    }
    .padding()
    .background(Color.background)
}
