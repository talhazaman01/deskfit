import SwiftUI
import UIKit

// MARK: - DeskFit Brand Palette (Base Colors)
// These are the raw color values. Use semantic tokens from AppTheme for actual UI.
// Premium Theme: Blue gradient background + Coral primary accent + Teal secondary accent

enum BrandColors {
    // MARK: - Blue Gradient Background (Calm-Style)

    /// Top of the blue gradient - lighter sky blue #67B7FF
    static let gradientTop = Color(hex: "67B7FF")

    /// Bottom of the blue gradient - deeper blue-violet #5A78FF
    static let gradientBottom = Color(hex: "5A78FF")

    /// Mid-point gradient color for smooth transitions #60A0FF
    static let gradientMid = Color(hex: "60A0FF")

    // MARK: - Glass/Surface Colors (White-based for blue backgrounds)

    /// Glass card surface - white at 12% opacity for subtle translucency
    static let surfaceGlass = Color.white.opacity(0.12)

    /// Strong glass surface - white at 18% opacity for emphasis
    static let surfaceGlassStrong = Color.white.opacity(0.18)

    /// Elevated surface (modals/sheets) - white at 22% opacity
    static let surfaceElevated = Color.white.opacity(0.22)

    /// Subtle stroke for glass cards - white at 15% opacity
    static let strokeGlass = Color.white.opacity(0.15)

    /// Strong stroke for selected/emphasized elements - white at 35% opacity
    static let strokeGlassStrong = Color.white.opacity(0.35)

    // MARK: - Text Colors (White-based for blue backgrounds)

    /// Primary text - pure white for maximum contrast
    static let textPrimary = Color.white

    /// Secondary text - white at 75% opacity
    static let textSecondary = Color.white.opacity(0.75)

    /// Tertiary text - white at 55% opacity
    static let textTertiary = Color.white.opacity(0.55)

    /// Placeholder text - white at 40% opacity
    static let textPlaceholder = Color.white.opacity(0.40)

    // MARK: - Primary Accent (CORAL) - For CTAs, selection, key highlights

    /// Primary coral - main CTA and selection color #FF5A66
    static let primaryCoral = Color(hex: "FF5A66")

    /// Coral pressed/darker state #E94B57
    static let primaryCoralPressed = Color(hex: "E94B57")

    /// Coral subtle tint for selected backgrounds - coral at 18% opacity
    static let primaryCoralTint = Color(hex: "FF5A66").opacity(0.18)

    /// Coral glow/shadow color - coral at 30% opacity
    static let primaryCoralGlow = Color(hex: "FF5A66").opacity(0.30)

    // MARK: - Secondary Accent (TEAL) - For secondary actions, progress, subtle icons

    /// Secondary teal - progress rings, secondary highlights #14B8A6
    static let secondaryTeal = Color(hex: "14B8A6")

    /// Teal subtle tint - teal at 20% opacity
    static let secondaryTealTint = Color(hex: "14B8A6").opacity(0.20)

    // MARK: - Legacy Accent Colors (Deprecated - use primaryCoral/secondaryTeal)

    /// @available(*, deprecated, message: "Use primaryCoral instead")
    static let accentPrimary = primaryCoral

    /// @available(*, deprecated, message: "Use primaryCoral instead")
    static let accentSecondary = primaryCoral

    /// @available(*, deprecated, message: "Use secondaryTeal instead")
    static let accentMuted = secondaryTeal

    /// @available(*, deprecated, message: "Use primaryCoralTint instead")
    static let accentSoft = primaryCoralTint

    // MARK: - Text on Accent

    /// Text on coral accent backgrounds (white for contrast)
    static let textOnAccent = Color.white

    /// Text on dark backgrounds (legacy - same as textOnAccent)
    static let textOnDark = Color.white

    // MARK: - Status Colors (Harmonized with theme)

    /// Success - teal for consistency #14B8A6
    static let success = secondaryTeal

    /// Warning - warm amber #FBBF24
    static let warning = Color(hex: "FBBF24")

    /// Destructive/error - soft red #FF6B6B
    static let destructive = Color(hex: "FF6B6B")

    /// Streak flame orange #F4A261
    static let flame = Color(hex: "F4A261")

    // MARK: - Pure Colors

    static let white = Color.white
    static let black = Color.black

    // MARK: - UIColor Versions (for UIKit APIs)

    static var gradientTopUI: UIColor { UIColor(gradientTop) }
    static var gradientBottomUI: UIColor { UIColor(gradientBottom) }
    static var gradientMidUI: UIColor { UIColor(gradientMid) }
    static var surfaceGlassUI: UIColor { UIColor(surfaceGlass) }
    static var surfaceGlassStrongUI: UIColor { UIColor(surfaceGlassStrong) }
    static var surfaceElevatedUI: UIColor { UIColor(surfaceElevated) }
    static var textPrimaryUI: UIColor { UIColor(textPrimary) }
    static var textSecondaryUI: UIColor { UIColor(textSecondary) }
    static var textTertiaryUI: UIColor { UIColor(textTertiary) }
    static var primaryCoralUI: UIColor { UIColor(primaryCoral) }
    static var primaryCoralPressedUI: UIColor { UIColor(primaryCoralPressed) }
    static var secondaryTealUI: UIColor { UIColor(secondaryTeal) }
    static var textOnAccentUI: UIColor { UIColor(textOnAccent) }
    static var successUI: UIColor { UIColor(success) }
    static var warningUI: UIColor { UIColor(warning) }
    static var destructiveUI: UIColor { UIColor(destructive) }
    static var flameUI: UIColor { UIColor(flame) }

    // Legacy UIColor versions
    static var accentPrimaryUI: UIColor { primaryCoralUI }
    static var accentSecondaryUI: UIColor { primaryCoralUI }
}

// MARK: - Gradient Helper

extension BrandColors {
    /// The main app background gradient (Calm-style blue)
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [gradientTop, gradientMid, gradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// A simpler two-color gradient for smaller elements
    static var simpleGradient: LinearGradient {
        LinearGradient(
            colors: [gradientTop, gradientBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
