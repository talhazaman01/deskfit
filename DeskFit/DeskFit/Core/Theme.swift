import SwiftUI
import UIKit

// MARK: - DeskFit Theme Colors (Single Source of Truth)

enum ThemeColor {
    // Core colors from Assets
    static let brandCeleste = Color("Theme/BrandCeleste")
    static let background = Color("Theme/BackgroundPrimary")
    static let surface = Color("Theme/Surface")
    static let accent = Color("Theme/Accent")
    static let textPrimary = Color("Theme/TextPrimary")
    static let textOnAccent = Color("Theme/TextOnAccent")

    // Derived colors (using opacity)
    static let textSecondary = textPrimary.opacity(0.75)
    static let textTertiary = textPrimary.opacity(0.55)
    static let separator = textPrimary.opacity(0.18)
    static let surfaceHighlight = textPrimary.opacity(0.08)

    // UIColor versions for UIKit configuration
    static var backgroundUI: UIColor { UIColor(background) }
    static var surfaceUI: UIColor { UIColor(surface) }
    static var accentUI: UIColor { UIColor(accent) }
    static var textPrimaryUI: UIColor { UIColor(textPrimary) }
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
        static let card = SwiftUI.Color.black.opacity(0.05)
        static let cardRadius: CGFloat = 8
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

    /// Apply card style (surface background, rounded corners)
    func cardStyle(isSelected: Bool = false) -> some View {
        self
            .padding(Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? ThemeColor.accent.opacity(0.2) : ThemeColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(isSelected ? ThemeColor.accent : Color.clear, lineWidth: 2)
            )
    }

    /// Apply DeskFit screen background (dark blue-teal, ignores safe area)
    /// Uses ZStack pattern to guarantee edge-to-edge coverage on all devices
    func deskFitScreenBackground() -> some View {
        ZStack {
            ThemeColor.background
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
                    .fill(ThemeColor.surface)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Primary CTA Button Style

struct PrimaryCTAButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.button)
            .foregroundStyle(isEnabled ? ThemeColor.textOnAccent : ThemeColor.textPrimary.opacity(0.5))
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Height.primaryButton)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.pill)
                    .fill(isEnabled ? ThemeColor.accent : ThemeColor.surface)
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
            .foregroundStyle(ThemeColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Height.primaryButton)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.pill)
                    .stroke(ThemeColor.separator, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
