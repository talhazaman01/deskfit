import SwiftUI
import UIKit

// MARK: - DeskFit Brand Palette (Base Colors)
// These are the raw color values. Use semantic tokens from AppTheme for actual UI.
// Premium Theme: Blue gradient background + Pink-Coral accent (unified)

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

    // MARK: - Primary Accent (PINK-CORAL) - For CTAs, selection, key highlights
    // Calm-style pink coral that reads premium and friendly (not red)

    /// Primary coral - main CTA and selection color #FF5A7A (pink coral)
    static let primaryCoral = Color(hex: "FF5A7A")

    /// Coral pressed/darker state #E94B6C
    static let primaryCoralPressed = Color(hex: "E94B6C")

    /// Coral subtle tint for selected backgrounds - coral at 18% opacity
    static let primaryCoralTint = Color(hex: "FF5A7A").opacity(0.18)

    /// Coral glow/shadow color - coral at 25% opacity (subtle)
    static let primaryCoralGlow = Color(hex: "FF5A7A").opacity(0.25)

    /// Coral stroke for outlines - coral at 70% opacity
    static let primaryCoralStroke = Color(hex: "FF5A7A").opacity(0.70)

    // MARK: - Secondary Accent (Unified with Coral)
    // All secondary accents now use coral for consistency

    /// Secondary accent - now unified with coral #FF5A7A
    static let secondaryCoral = primaryCoral

    /// Secondary subtle tint - coral at 18% opacity
    static let secondaryCoralTint = primaryCoralTint

    // MARK: - Legacy Teal (Deprecated - mapped to coral)
    /// @available(*, deprecated, message: "Use primaryCoral instead - teal accent removed")
    static let secondaryTeal = primaryCoral

    /// @available(*, deprecated, message: "Use primaryCoralTint instead - teal accent removed")
    static let secondaryTealTint = primaryCoralTint

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

    /// Success - soft green #22C55E (distinct from coral accent)
    static let success = Color(hex: "22C55E")

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
    static var primaryCoralStrokeUI: UIColor { UIColor(primaryCoralStroke) }
    /// @available(*, deprecated, message: "Use primaryCoralUI instead")
    static var secondaryTealUI: UIColor { UIColor(primaryCoral) }
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
