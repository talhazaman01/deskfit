import SwiftUI
import UIKit

// MARK: - DeskFit Theme Colors (Bridging Layer)
// ThemeColor now bridges to AppTheme tokens for backward compatibility.
// All new code should use AppTheme directly.

enum ThemeColor {
    // MARK: - Core Colors (From AppTheme)

    /// Brand highlight color - now accent cyan
    static let brandCeleste = AppTheme.brandCeleste

    /// App background - blue gradient mid color
    static let background = AppTheme.appBackground

    /// Card/surface background - glass effect
    static let surface = AppTheme.cardBackground

    /// Elevated surface for modals/sheets
    static let surfaceElevated = AppTheme.surfaceElevated

    /// Primary accent - bright cyan
    static let accent = AppTheme.accent

    /// Muted accent
    static let accentMuted = AppTheme.accentMuted

    /// Primary text color - white
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

    /// Default border
    static let border = AppTheme.border

    // MARK: - UIColor Versions (for UIKit APIs)

    static var backgroundUI: UIColor { AppTheme.appBackgroundUI }
    static var surfaceUI: UIColor { AppTheme.cardBackgroundUI }
    static var surfaceElevatedUI: UIColor { AppTheme.surfaceElevatedUI }
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
        static let xl: CGFloat = 20

        /// Pill button radius
        static let pill: CGFloat = 28
    }

    // MARK: - Typography (SF Pro Rounded for premium feel)

    enum Typography {
        // Large title for onboarding questions - bold rounded
        static let largeTitle = Font.system(size: 28, weight: .bold, design: .rounded)

        // Screen titles - bold rounded
        static let title = Font.system(size: 24, weight: .bold, design: .rounded)

        // Section headers - semibold rounded
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)

        // Body text - regular rounded
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)

        // Subtitle/description text - regular rounded
        static let subtitle = Font.system(size: 15, weight: .regular, design: .rounded)

        // Small labels - regular rounded
        static let caption = Font.system(size: 13, weight: .regular, design: .rounded)

        // Button text - semibold rounded
        static let button = Font.system(size: 17, weight: .semibold, design: .rounded)

        // Card option text - medium rounded
        static let option = Font.system(size: 17, weight: .medium, design: .rounded)

        // Card description text - regular rounded
        static let optionDescription = Font.system(size: 13, weight: .regular, design: .rounded)

        // Extra large display numbers
        static let display = Font.system(size: 48, weight: .bold, design: .rounded)

        // Medium weight body
        static let bodyMedium = Font.system(size: 17, weight: .medium, design: .rounded)
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

    /// Apply card style with selection state (glass background, rounded corners, border)
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
