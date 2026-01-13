import SwiftUI
import UIKit

// MARK: - DeskFit Brand Palette (Base Colors)
// These are the raw color values. Use semantic tokens from AppTheme for actual UI.
// Premium Teal Theme - Deep, sophisticated teal with bright aqua accents

enum BrandColors {
    // MARK: - Primary Teal Backgrounds (Dark Mode Base)

    /// Deep teal for dark mode app background - #062B2D
    /// Rich, premium feel without being too dark
    static let tealDeep = Color(hex: "062B2D")

    /// Card/surface teal - #0B3A3D
    /// Slightly lighter than background for card elevation
    static let tealSurface = Color(hex: "0B3A3D")

    /// Elevated surface teal (modals/sheets) - #0F4548
    /// Even lighter for top-level surfaces
    static let tealElevated = Color(hex: "0F4548")

    /// Border teal - #2A6C70
    /// Visible but not harsh borders
    static let tealBorder = Color(hex: "2A6C70")

    // MARK: - Light Mode Backgrounds

    /// Near-white teal tint for light mode background - #F5FEFE
    /// Clean, premium light mode
    static let lightBackground = Color(hex: "F5FEFE")

    /// Pure white for light mode surfaces - #FFFFFF
    static let lightSurface = Color.white

    /// Light elevated surface (modals) - #ECFBFB
    /// Subtle teal tint
    static let lightElevated = Color(hex: "ECFBFB")

    /// Light mode border - #CBECEC
    static let lightBorder = Color(hex: "CBECEC")

    // MARK: - Text Colors

    /// Deep teal for light mode text - #062B2D
    static let textDark = Color(hex: "062B2D")

    /// Secondary text for light mode - #245053
    static let textDarkSecondary = Color(hex: "245053")

    /// White for dark mode text
    static let textLight = Color.white

    // MARK: - Accent Colors (Same across modes)

    /// Primary accent - bright aqua/teal - #2FE6E6
    /// Used for CTAs, selection highlights, interactive elements
    static let accent = Color(hex: "2FE6E6")

    /// Muted accent - #1BB9B9
    /// Secondary highlights, less prominent interactions
    static let accentMuted = Color(hex: "1BB9B9")

    // MARK: - Status Colors

    /// Destructive/error - #FF4D4D
    static let destructive = Color(hex: "FF4D4D")

    /// Success (optional, use sparingly) - #2FE6B8
    static let success = Color(hex: "2FE6B8")

    /// Warning amber - #FBBF24
    static let warning = Color(hex: "FBBF24")

    /// Streak flame orange - #F4A261
    static let flame = Color(hex: "F4A261")

    // MARK: - Pure Colors

    static let white = Color.white
    static let black = Color.black

    // MARK: - UIColor Versions (for UIKit APIs)

    static var tealDeepUI: UIColor { UIColor(tealDeep) }
    static var tealSurfaceUI: UIColor { UIColor(tealSurface) }
    static var tealElevatedUI: UIColor { UIColor(tealElevated) }
    static var tealBorderUI: UIColor { UIColor(tealBorder) }
    static var lightBackgroundUI: UIColor { UIColor(lightBackground) }
    static var lightSurfaceUI: UIColor { UIColor(lightSurface) }
    static var lightElevatedUI: UIColor { UIColor(lightElevated) }
    static var lightBorderUI: UIColor { UIColor(lightBorder) }
    static var textDarkUI: UIColor { UIColor(textDark) }
    static var accentUI: UIColor { UIColor(accent) }
    static var accentMutedUI: UIColor { UIColor(accentMuted) }
}

// MARK: - Adaptive Color Helper

extension BrandColors {
    /// Creates a color that adapts to light/dark mode
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// Creates a UIColor that adapts to light/dark mode
    static func adaptiveUI(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        }
    }
}
