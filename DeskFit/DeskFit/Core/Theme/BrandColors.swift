import SwiftUI
import UIKit

// MARK: - DeskFit Brand Palette (Base Colors)
// These are the raw color values. Use semantic tokens from AppTheme for actual UI.

enum BrandColors {
    // MARK: - Primary Brand Colors

    /// Main brand light blue - #B2FFFF
    /// Use as accent fill and selection highlight
    static let celeste = Color(hex: "B2FFFF")

    /// Very light Celeste tint for backgrounds - #E9FFFF
    /// Use for light mode app background
    static let celesteTint = Color(hex: "E9FFFF")

    // MARK: - Navy Colors (Ink System)

    /// Deep navy for text/icons - #062A3A
    /// Primary ink color on light backgrounds
    static let navyInk = Color(hex: "062A3A")

    /// Slightly lighter navy for dark surfaces - #083446
    /// Card backgrounds in dark mode
    static let navySurface = Color(hex: "083446")

    /// Darkest navy for dark mode background - #041A24
    /// App background in dark mode
    static let navyDeep = Color(hex: "041A24")

    // MARK: - Accent Colors

    /// Accent teal that pops on both modes - #22D3EE
    /// Interactive elements, links, selected states
    static let accentTeal = Color(hex: "22D3EE")

    /// Success/action mint teal - #2EE6C5
    /// CTAs, success states, primary buttons
    static let mintAction = Color(hex: "2EE6C5")

    // MARK: - Status Colors

    /// Warning amber - #FBBF24
    static let warning = Color(hex: "FBBF24")

    /// Danger/error rose - #FB7185
    static let danger = Color(hex: "FB7185")

    /// Warm coral for streaks/celebrations - #E07A5F
    static let coral = Color(hex: "E07A5F")

    /// Streak flame orange - #F4A261
    static let flame = Color(hex: "F4A261")

    // MARK: - Pure Colors

    static let white = Color.white
    static let black = Color.black

    // MARK: - UIColor Versions (for UIKit APIs)

    static var celesteUI: UIColor { UIColor(celeste) }
    static var celesteTintUI: UIColor { UIColor(celesteTint) }
    static var navyInkUI: UIColor { UIColor(navyInk) }
    static var navySurfaceUI: UIColor { UIColor(navySurface) }
    static var navyDeepUI: UIColor { UIColor(navyDeep) }
    static var accentTealUI: UIColor { UIColor(accentTeal) }
    static var mintActionUI: UIColor { UIColor(mintAction) }
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
