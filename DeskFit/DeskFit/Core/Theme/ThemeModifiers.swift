import SwiftUI

// MARK: - Screen Background Modifier (Calm-Style Gradient)

struct DeskFitScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Full-screen blue gradient background
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

// MARK: - Glass Card Style Modifier

struct DeskFitCardStyleModifier: ViewModifier {
    var padding: CGFloat = Theme.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .strokeBorder(AppTheme.strokeSubtle, lineWidth: 1)
            )
    }
}

// MARK: - Strong Glass Card Style Modifier

struct DeskFitCardStrongStyleModifier: ViewModifier {
    var padding: CGFloat = Theme.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(AppTheme.cardBackgroundStrong)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .strokeBorder(AppTheme.strokeSubtle, lineWidth: 1)
            )
    }
}

// MARK: - Selectable Row Modifier (High Contrast Selection)

struct DeskFitSelectableRowModifier: ViewModifier {
    let isSelected: Bool
    var height: CGFloat? = nil

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .frame(height: height)
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
    }
}

// MARK: - View Extensions

extension View {
    /// Apply DeskFit screen background (Calm-style blue gradient)
    func deskFitScreenBackground() -> some View {
        modifier(DeskFitScreenBackgroundModifier())
    }

    /// Legacy alias for screen background
    func celesteScreenBackground() -> some View {
        modifier(DeskFitScreenBackgroundModifier())
    }

    /// Apply glass card container style
    func deskFitCardStyle(padding: CGFloat = Theme.Spacing.lg) -> some View {
        modifier(DeskFitCardStyleModifier(padding: padding))
    }

    /// Apply strong glass card container style
    func deskFitCardStrongStyle(padding: CGFloat = Theme.Spacing.lg) -> some View {
        modifier(DeskFitCardStrongStyleModifier(padding: padding))
    }

    /// Legacy alias for card style
    func celesteCardStyle(padding: CGFloat = Theme.Spacing.lg) -> some View {
        modifier(DeskFitCardStyleModifier(padding: padding))
    }

    /// Apply selectable row/card style with selection state
    func deskFitSelectableRow(isSelected: Bool, height: CGFloat? = nil) -> some View {
        modifier(DeskFitSelectableRowModifier(isSelected: isSelected, height: height))
    }

    /// Legacy alias for selectable row
    func celesteSelectableRow(isSelected: Bool, height: CGFloat? = nil) -> some View {
        modifier(DeskFitSelectableRowModifier(isSelected: isSelected, height: height))
    }
}

// MARK: - Primary Button Style

struct DeskFitPrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.button)
            .foregroundStyle(isEnabled ? AppTheme.primaryActionFg : AppTheme.disabledFg)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Height.primaryButton)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.pill)
                    .fill(isEnabled ? AppTheme.primaryActionBg : AppTheme.disabledBg)
            )
            .shadow(
                color: isEnabled ? AppTheme.shadowColor : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Legacy alias
typealias CelestePrimaryButtonStyle = DeskFitPrimaryButtonStyle

// MARK: - Secondary Button Style

struct DeskFitSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.button)
            .foregroundStyle(AppTheme.secondaryActionFg)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Height.primaryButton)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.pill)
                    .stroke(AppTheme.secondaryActionStroke, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Legacy alias
typealias CelesteSecondaryButtonStyle = DeskFitSecondaryButtonStyle

// MARK: - Selection Checkmark Component

struct SelectionCheckmark: View {
    var size: CGFloat = 24
    var iconSize: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.selectionCheck)
                .frame(width: size, height: size)

            Image(systemName: "checkmark")
                .font(.system(size: iconSize, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textOnAccent)
        }
    }
}

// MARK: - Button Style Extensions

extension View {
    /// Apply primary CTA button style (accent cyan background with shadow)
    func deskFitPrimaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(DeskFitPrimaryButtonStyle(isEnabled: isEnabled))
    }

    /// Legacy alias
    func celestePrimaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(DeskFitPrimaryButtonStyle(isEnabled: isEnabled))
    }

    /// Apply secondary outline button style
    func deskFitSecondaryButton() -> some View {
        self.buttonStyle(DeskFitSecondaryButtonStyle())
    }

    /// Legacy alias
    func celesteSecondaryButton() -> some View {
        self.buttonStyle(DeskFitSecondaryButtonStyle())
    }
}

// MARK: - Theme Preview Gallery

#Preview("Theme Gallery - Calm Blue") {
    ScrollView {
        VStack(spacing: 24) {
            // Background colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Backgrounds")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                HStack(spacing: 12) {
                    colorSwatch("Glass Card", AppTheme.cardBackground)
                    colorSwatch("Strong Card", AppTheme.cardBackgroundStrong)
                    colorSwatch("Elevated", AppTheme.surfaceElevated)
                }
            }

            // Text colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Text Colors")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Primary Text")
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Secondary Text")
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("Tertiary Text")
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }

            // Accent colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Accents")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                HStack(spacing: 12) {
                    colorSwatch("Primary", AppTheme.accent)
                    colorSwatch("Secondary", AppTheme.accentSecondary)
                    colorSwatch("Muted", AppTheme.accentMuted)
                }
            }

            // Selection states
            VStack(alignment: .leading, spacing: 8) {
                Text("Selection States")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                VStack(spacing: 12) {
                    selectionRowPreview(isSelected: false, title: "Unselected Row")
                    selectionRowPreview(isSelected: true, title: "Selected Row")
                }
            }

            // Buttons
            VStack(alignment: .leading, spacing: 8) {
                Text("Buttons")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Button("Primary Button") {}
                    .deskFitPrimaryButton()

                Button("Disabled Button") {}
                    .deskFitPrimaryButton(isEnabled: false)

                Button("Secondary Button") {}
                    .deskFitSecondaryButton()
            }
        }
        .padding()
    }
    .deskFitScreenBackground()
}

// MARK: - Preview Helpers

@ViewBuilder
private func colorSwatch(_ name: String, _ color: Color) -> some View {
    VStack(spacing: 4) {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(width: 60, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.strokeSubtle, lineWidth: 1)
            )
        Text(name)
            .font(.caption2)
            .foregroundStyle(AppTheme.textSecondary)
    }
}

@ViewBuilder
private func selectionRowPreview(isSelected: Bool, title: String) -> some View {
    HStack {
        Text(title)
            .font(Theme.Typography.option)
            .foregroundStyle(AppTheme.textPrimary)
        Spacer()
        if isSelected {
            SelectionCheckmark()
        }
    }
    .deskFitSelectableRow(isSelected: isSelected, height: 56)
}
