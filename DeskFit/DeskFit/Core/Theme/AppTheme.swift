import SwiftUI
import UIKit

// MARK: - DeskFit Semantic Color Tokens
// Single source of truth for all UI colors.
// Calm-Style Blue Gradient Theme with glass cards and white text.

enum AppTheme {
    // MARK: - Background Tokens

    /// The main app background gradient (use with dfScreenBackground modifier)
    static var backgroundGradient: LinearGradient {
        BrandColors.backgroundGradient
    }

    /// Solid background color fallback (mid-gradient color)
    static let appBackground = BrandColors.gradientMid

    /// Top of gradient for UIKit
    static let gradientTop = BrandColors.gradientTop

    /// Bottom of gradient for UIKit
    static let gradientBottom = BrandColors.gradientBottom

    // MARK: - Surface/Card Tokens (Glass effect)

    /// Glass card background - subtle white translucency
    static let cardBackground = BrandColors.surfaceGlass

    /// Strong glass card - more prominent white translucency
    static let cardBackgroundStrong = BrandColors.surfaceGlassStrong

    /// Elevated surface for modals/sheets
    static let surfaceElevated = BrandColors.surfaceElevated

    /// Alternate surface for nested cards
    static let surfaceAlt = BrandColors.surfaceGlassStrong

    // MARK: - Text Tokens

    /// Primary text - pure white
    static let textPrimary = BrandColors.textPrimary

    /// Secondary text - white at 75%
    static let textSecondary = BrandColors.textSecondary

    /// Tertiary text - white at 55%
    static let textTertiary = BrandColors.textTertiary

    /// Placeholder text - white at 40%
    static let textPlaceholder = BrandColors.textPlaceholder

    /// Text on accent backgrounds (dark for contrast)
    static let textOnAccent = BrandColors.textOnAccent

    /// Text on primary action buttons
    static let textOnPrimary = BrandColors.textOnAccent

    // MARK: - Accent & Brand Tokens

    /// Primary accent color - bright cyan #37D6E6
    static let accent = BrandColors.accentPrimary

    /// Secondary accent - bright blue #2BB4FF
    static let accentSecondary = BrandColors.accentSecondary

    /// Muted accent for subtle highlights
    static let accentMuted = BrandColors.accentMuted

    /// Soft accent for subtle highlights (cyan at 25%)
    static let accentSoft = BrandColors.accentSoft

    /// Brand highlight (legacy support)
    static let brandCeleste = BrandColors.accentPrimary

    // MARK: - Action Button Tokens

    /// Primary CTA background - uses bright cyan accent
    static let primaryActionBg = BrandColors.accentPrimary

    /// Primary CTA text - dark for contrast
    static let primaryActionFg = BrandColors.textOnAccent

    /// Secondary action stroke color - white at 30%
    static let secondaryActionStroke = Color.white.opacity(0.30)

    /// Secondary action text color - white
    static let secondaryActionFg = BrandColors.textPrimary

    /// Disabled button background - white at 8%
    static let disabledBg = Color.white.opacity(0.08)

    /// Disabled button/text color - white at 40%
    static let disabledFg = Color.white.opacity(0.40)

    // MARK: - Border/Stroke Tokens

    /// Default border - subtle white stroke
    static let border = BrandColors.strokeGlass

    /// Subtle stroke for unselected cards/borders
    static let strokeSubtle = BrandColors.strokeGlass

    /// Strong stroke for selected/emphasized elements
    static let strokeStrong = BrandColors.strokeGlassStrong

    /// Divider/separator color
    static let divider = Color.white.opacity(0.12)

    // MARK: - Selection State Tokens (High Contrast)

    /// Selectable card default background (same as cardBackground)
    static let selectableDefault = cardBackground

    /// Selectable card selected fill - accent at 22% opacity
    static let selectionFill = BrandColors.accentPrimary.opacity(0.22)

    /// Selectable card selected stroke - bright accent secondary
    static let selectionStroke = BrandColors.accentSecondary

    /// Selection checkmark/indicator color - bright cyan accent
    static let selectionCheck = BrandColors.accentPrimary

    // MARK: - Tab Bar Tokens

    /// Tab bar background - glass effect on gradient
    static let tabBarBg = Color.white.opacity(0.10)

    /// Tab bar selected icon/text - uses accent for visibility
    static let tabBarSelected = BrandColors.accentPrimary

    /// Tab bar unselected icon/text - white at 60%
    static let tabBarUnselected = Color.white.opacity(0.60)

    // MARK: - Progress Ring Tokens

    /// Progress ring track (background) - white at 15%
    static let progressRingTrack = Color.white.opacity(0.15)

    /// Progress ring fill (foreground) - accent cyan
    static let progressRingFill = BrandColors.accentPrimary

    // MARK: - Status Tokens

    static let success = BrandColors.success
    static let warning = BrandColors.warning
    static let danger = BrandColors.destructive
    static let destructive = BrandColors.destructive
    static let streakFlame = BrandColors.flame

    // MARK: - Shadow Tokens

    static let shadowColor = Color.black.opacity(0.20)
    static let shadowRadius: CGFloat = 12
    static let shadowY: CGFloat = 6

    // MARK: - UIColor Versions (for UIKit APIs)

    static var appBackgroundUI: UIColor {
        BrandColors.gradientMidUI
    }

    static var gradientTopUI: UIColor {
        BrandColors.gradientTopUI
    }

    static var gradientBottomUI: UIColor {
        BrandColors.gradientBottomUI
    }

    static var cardBackgroundUI: UIColor {
        BrandColors.surfaceGlassUI
    }

    static var surfaceElevatedUI: UIColor {
        BrandColors.surfaceElevatedUI
    }

    static var textPrimaryUI: UIColor {
        BrandColors.textPrimaryUI
    }

    static var textSecondaryUI: UIColor {
        BrandColors.textSecondaryUI
    }

    static var accentUI: UIColor {
        BrandColors.accentPrimaryUI
    }

    static var tabBarSelectedUI: UIColor {
        BrandColors.accentPrimaryUI
    }

    static var tabBarUnselectedUI: UIColor {
        UIColor.white.withAlphaComponent(0.60)
    }

    static var tabBarBgUI: UIColor {
        UIColor.white.withAlphaComponent(0.10)
    }
}

// MARK: - Icon Color Helpers

extension AppTheme {
    /// Icon color that matches text primary
    static let iconPrimary = textPrimary

    /// Icon color that matches text secondary
    static let iconSecondary = textSecondary

    /// Icon color for selected states
    static let iconSelected = selectionCheck

    /// Icon color on accent backgrounds
    static let iconOnAccent = textOnAccent
}
