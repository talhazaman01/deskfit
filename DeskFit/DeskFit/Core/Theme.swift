import SwiftUI
import UIKit

// MARK: - DeskFit Theme Colors (Bridging Layer)
// ThemeColor now bridges to AppTheme tokens for backward compatibility.
// All new code should use AppTheme directly.

enum ThemeColor {
    // MARK: - Core Colors (Now Dynamic via AppTheme)

    /// Brand Celeste highlight color
    static let brandCeleste = AppTheme.brandCeleste

    /// App background - Celeste tint (light) / Deep navy (dark)
    static let background = AppTheme.appBackground

    /// Card/surface background
    static let surface = AppTheme.cardBackground

    /// Primary accent - teal
    static let accent = AppTheme.accent

    /// Primary text color (adapts to mode)
    static let textPrimary = AppTheme.textPrimary

    /// Text on accent backgrounds
    static let textOnAccent = AppTheme.textOnAccent

    // MARK: - Derived Text Colors

    static let textSecondary = AppTheme.textSecondary
    static let textTertiary = AppTheme.textTertiary
    static let separator = AppTheme.divider
    static let surfaceHighlight = AppTheme.accentSoft

    // MARK: - Selection State Colors

    /// Card background when selected
    static let cardSelectedBackground = AppTheme.selectionFill

    /// Border color for unselected cards
    static let borderDefault = AppTheme.strokeSubtle

    /// Border color for selected cards
    static let borderSelected = AppTheme.selectionStroke

    // MARK: - UIColor Versions (for UIKit APIs)

    static var backgroundUI: UIColor { AppTheme.appBackgroundUI }
    static var surfaceUI: UIColor { AppTheme.cardBackgroundUI }
    static var accentUI: UIColor { AppTheme.accentUI }
    static var textPrimaryUI: UIColor { AppTheme.textPrimaryUI }
}

// MARK: - DeskFit Theme Constants

enum Theme {
    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32

        /// Horizontal screen padding
        static let screenHorizontal: CGFloat = 20

        /// Vertical padding for bottom CTA area
        static let bottomArea: CGFloat = 34
    }

    // MARK: - Corner Radius

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16

        /// Pill button radius
        static let pill: CGFloat = 28
    }

    // MARK: - Typography

    enum Typography {
        // Large title for onboarding questions
        static let largeTitle = Font.system(size: 28, weight: .bold)

        // Screen titles
        static let title = Font.system(size: 24, weight: .bold)

        // Section headers
        static let headline = Font.system(size: 17, weight: .semibold)

        // Body text
        static let body = Font.system(size: 17, weight: .regular)

        // Subtitle/description text
        static let subtitle = Font.system(size: 15, weight: .regular)

        // Small labels
        static let caption = Font.system(size: 13, weight: .regular)

        // Button text
        static let button = Font.system(size: 17, weight: .semibold)

        // Card option text
        static let option = Font.system(size: 17, weight: .medium)

        // Card description text
        static let optionDescription = Font.system(size: 13, weight: .regular)
    }

    // MARK: - Shadows

    enum Shadow {
        static let card = AppTheme.shadowColor
        static let cardRadius: CGFloat = AppTheme.shadowRadius
    }

    // MARK: - Animation

    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)
    }

    // MARK: - Component Heights

    enum Height {
        static let optionCard: CGFloat = 56
        static let optionCardWithDescription: CGFloat = 72
        static let primaryButton: CGFloat = 56
        static let progressBar: CGFloat = 4
    }
}

// MARK: - View Modifiers

extension View {
    /// Apply standard screen padding
    func screenPadding() -> some View {
        self.padding(.horizontal, Theme.Spacing.screenHorizontal)
    }

    /// Apply card style with selection state (surface background, rounded corners, border)
    func cardStyle(isSelected: Bool = false) -> some View {
        self
            .padding(Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
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

    /// Apply DeskFit screen background (adapts to light/dark mode)
    /// Uses ZStack pattern to guarantee edge-to-edge coverage on all devices
    func deskFitScreenBackground() -> some View {
        ZStack {
            AppTheme.appBackground
                .ignoresSafeArea()
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// Apply DeskFit card style (surface background, rounded corners, subtle shadow)
    func deskFitCardStyle() -> some View {
        self
            .padding(Theme.Spacing.lg)
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

// MARK: - Primary CTA Button Style

struct PrimaryCTAButtonStyle: ButtonStyle {
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

struct SecondaryCTAButtonStyle: ButtonStyle {
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
