import SwiftUI

/// Focus area selection chip for onboarding (2-column grid)
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
                    .font(.system(size: 28))
                    .foregroundStyle(isSelected ? .textOnDark : .appTeal)

                Text(area.displayName)
                    .font(Theme.Typography.option)
                    .foregroundStyle(isSelected ? .textOnDark : .textPrimary)
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
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        FocusAreaChip(area: .neck, isSelected: true) {}
        FocusAreaChip(area: .shoulders, isSelected: false) {}
        FocusAreaChip(area: .lowerBack, isSelected: false) {}
        FocusAreaChip(area: .wrists, isSelected: true) {}
    }
    .padding()
}
