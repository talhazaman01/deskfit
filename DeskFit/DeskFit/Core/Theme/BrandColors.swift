import SwiftUI
import UIKit

// MARK: - DeskFit Brand Palette (Base Colors)
// These are the raw color values. Use semantic tokens from AppTheme for actual UI.
// Calm-Style Blue Gradient Theme - Premium, relaxing blue with bright cyan accents

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

    // MARK: - Accent Colors (Premium Cyan/Blue)

    /// Primary accent - bright cyan for CTAs #37D6E6
    static let accentPrimary = Color(hex: "37D6E6")

    /// Secondary accent - bright blue for selections #2BB4FF
    static let accentSecondary = Color(hex: "2BB4FF")

    /// Muted accent - softer cyan #1BBFCF
    static let accentMuted = Color(hex: "1BBFCF")

    /// Soft accent for subtle highlights - cyan at 25% opacity
    static let accentSoft = Color(hex: "37D6E6").opacity(0.25)

    // MARK: - Text on Accent

    /// Text on accent backgrounds (dark for contrast on cyan)
    static let textOnAccent = Color(hex: "0A2540")

    // MARK: - Status Colors (Harmonized with blue theme)

    /// Success - teal-green harmonized with blue #2FE6B8
    static let success = Color(hex: "2FE6B8")

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
    static var accentPrimaryUI: UIColor { UIColor(accentPrimary) }
    static var accentSecondaryUI: UIColor { UIColor(accentSecondary) }
    static var textOnAccentUI: UIColor { UIColor(textOnAccent) }
    static var successUI: UIColor { UIColor(success) }
    static var warningUI: UIColor { UIColor(warning) }
    static var destructiveUI: UIColor { UIColor(destructive) }
    static var flameUI: UIColor { UIColor(flame) }
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
