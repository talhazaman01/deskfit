import SwiftUI

// MARK: - Screen Background Modifier

struct DeskFitScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            AppTheme.appBackground
                .ignoresSafeArea()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Card Style Modifier

struct DeskFitCardStyleModifier: ViewModifier {
    var padding: CGFloat = Theme.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(AppTheme.cardBackground)
            )
            .shadow(
                color: AppTheme.shadowColor,
                radius: AppTheme.shadowRadius,
                x: 0,
                y: AppTheme.shadowY
            )
    }
}

// MARK: - Selectable Row Modifier

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
    /// Apply Celeste-theme screen background (adapts to light/dark mode)
    func celesteScreenBackground() -> some View {
        modifier(DeskFitScreenBackgroundModifier())
    }

    /// Apply card container style with shadow
    func celesteCardStyle(padding: CGFloat = Theme.Spacing.lg) -> some View {
        modifier(DeskFitCardStyleModifier(padding: padding))
    }

    /// Apply selectable row/card style with selection state
    func celesteSelectableRow(isSelected: Bool, height: CGFloat? = nil) -> some View {
        modifier(DeskFitSelectableRowModifier(isSelected: isSelected, height: height))
    }
}

// MARK: - Primary Button Style

struct CelestePrimaryButtonStyle: ButtonStyle {
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
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

struct CelesteSecondaryButtonStyle: ButtonStyle {
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
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(AppTheme.textOnAccent)
        }
    }
}

// MARK: - Button Style Extensions

extension View {
    /// Apply primary CTA button style (mint action background)
    func celestePrimaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(CelestePrimaryButtonStyle(isEnabled: isEnabled))
    }

    /// Apply secondary outline button style
    func celesteSecondaryButton() -> some View {
        self.buttonStyle(CelesteSecondaryButtonStyle())
    }
}
