import SwiftUI

/// Focus area selection chip for onboarding (2-column grid)
/// Features: border, background tint, and checkmark badge when selected
struct FocusAreaChip: View {
    let area: FocusArea
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: area.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(isSelected ? .appTeal : .appTeal.opacity(0.7))

                    Text(area.displayName)
                        .font(Theme.Typography.option)
                        .foregroundStyle(.textPrimary)
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

                // Selection checkmark badge
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.appTeal)
                            .frame(width: 22, height: 22)

                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.textOnAccent)
                    }
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

#Preview("Focus Area Chips") {
    VStack(spacing: 16) {
        Text("Multi-Select Focus Areas")
            .font(Theme.Typography.headline)
            .foregroundStyle(.textPrimary)

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            FocusAreaChip(area: .neck, isSelected: true) {}
            FocusAreaChip(area: .shoulders, isSelected: false) {}
            FocusAreaChip(area: .lowerBack, isSelected: false) {}
            FocusAreaChip(area: .wrists, isSelected: true) {}
            FocusAreaChip(area: .upperBack, isSelected: false) {}
            FocusAreaChip(area: .hips, isSelected: true) {}
        }
    }
    .padding()
    .deskFitScreenBackground()
}

#Preview("Dark Mode") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        FocusAreaChip(area: .neck, isSelected: true) {}
        FocusAreaChip(area: .shoulders, isSelected: false) {}
    }
    .padding()
    .deskFitScreenBackground()
    .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        FocusAreaChip(area: .neck, isSelected: true) {}
        FocusAreaChip(area: .shoulders, isSelected: false) {}
    }
    .padding()
    .deskFitScreenBackground()
    .preferredColorScheme(.light)
}
