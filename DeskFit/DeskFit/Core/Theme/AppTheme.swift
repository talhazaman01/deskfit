import SwiftUI
import UIKit

// MARK: - DeskFit Semantic Color Tokens
// Single source of truth for all UI colors. All tokens adapt to light/dark mode.
// Premium Teal Theme with high-contrast selection states

enum AppTheme {
    // MARK: - Background Tokens

    /// Main app background - Light teal tint (light) / Deep teal (dark)
    static let appBackground = BrandColors.adaptive(
        light: BrandColors.lightBackground,
        dark: BrandColors.tealDeep
    )

    /// Card/surface background - White (light) / Teal surface (dark)
    static let cardBackground = BrandColors.adaptive(
        light: BrandColors.lightSurface,
        dark: BrandColors.tealSurface
    )

    /// Elevated surface for modals/sheets - Light elevated (light) / Teal elevated (dark)
    static let surfaceElevated = BrandColors.adaptive(
        light: BrandColors.lightElevated,
        dark: BrandColors.tealElevated
    )

    /// Alternate surface for nested cards
    static let surfaceAlt = BrandColors.adaptive(
        light: BrandColors.lightElevated,
        dark: BrandColors.tealElevated
    )

    // MARK: - Text Tokens

    /// Primary text - Deep teal (light) / White (dark)
    static let textPrimary = BrandColors.adaptive(
        light: BrandColors.textDark,
        dark: BrandColors.textLight
    )

    /// Secondary text - Teal secondary (light) / White at 75% (dark)
    static let textSecondary = BrandColors.adaptive(
        light: BrandColors.textDarkSecondary,
        dark: BrandColors.textLight.opacity(0.75)
    )

    /// Tertiary text - Teal at 60% (light) / White at 55% (dark)
    static let textTertiary = BrandColors.adaptive(
        light: BrandColors.textDark.opacity(0.60),
        dark: BrandColors.textLight.opacity(0.55)
    )

    /// Text on accent backgrounds (teal buttons, selection fills)
    static let textOnAccent = BrandColors.textDark

    /// Text on primary action buttons
    static let textOnPrimary = BrandColors.textDark

    // MARK: - Accent & Brand Tokens

    /// Primary accent color - Bright aqua teal #2FE6E6
    static let accent = BrandColors.accent

    /// Muted accent - #1BB9B9
    static let accentMuted = BrandColors.accentMuted

    /// Soft accent for subtle highlights
    static let accentSoft = BrandColors.adaptive(
        light: BrandColors.accent.opacity(0.15),
        dark: BrandColors.accent.opacity(0.20)
    )

    /// Brand highlight (legacy support)
    static let brandCeleste = BrandColors.accent

    // MARK: - Action Button Tokens

    /// Primary CTA background (Start Session, Continue) - uses bright accent
    static let primaryActionBg = BrandColors.accent

    /// Primary CTA text
    static let primaryActionFg = BrandColors.textDark

    /// Secondary action stroke color
    static let secondaryActionStroke = BrandColors.adaptive(
        light: BrandColors.textDark.opacity(0.25),
        dark: BrandColors.textLight.opacity(0.30)
    )

    /// Secondary action text color
    static let secondaryActionFg = BrandColors.adaptive(
        light: BrandColors.textDark,
        dark: BrandColors.textLight
    )

    /// Disabled button background
    static let disabledBg = BrandColors.adaptive(
        light: Color(hex: "E0E8E8"),
        dark: BrandColors.tealSurface
    )

    /// Disabled button/text color
    static let disabledFg = BrandColors.adaptive(
        light: BrandColors.textDark.opacity(0.40),
        dark: BrandColors.textLight.opacity(0.40)
    )

    // MARK: - Border/Stroke Tokens

    /// Default border - Teal border (light) / White 15% (dark)
    static let border = BrandColors.adaptive(
        light: BrandColors.lightBorder,
        dark: BrandColors.textLight.opacity(0.15)
    )

    /// Subtle stroke for unselected cards/borders
    static let strokeSubtle = BrandColors.adaptive(
        light: BrandColors.lightBorder,
        dark: BrandColors.textLight.opacity(0.12)
    )

    /// Strong stroke for selected/emphasized elements
    static let strokeStrong = BrandColors.adaptive(
        light: BrandColors.accent,
        dark: BrandColors.accent
    )

    /// Divider/separator color
    static let divider = BrandColors.adaptive(
        light: BrandColors.lightBorder,
        dark: BrandColors.textLight.opacity(0.15)
    )

    // MARK: - Selection State Tokens (High Contrast)

    /// Selectable card default background (same as cardBackground)
    static let selectableDefault = cardBackground

    /// Selectable card selected fill - accent at ~20% opacity
    static let selectionFill = BrandColors.adaptive(
        light: BrandColors.accent.opacity(0.18),
        dark: BrandColors.accent.opacity(0.22)
    )

    /// Selectable card selected stroke - bright accent (2px)
    static let selectionStroke = BrandColors.accent

    /// Selection checkmark/indicator color - bright accent
    static let selectionCheck = BrandColors.accent

    // MARK: - Tab Bar Tokens

    /// Tab bar background
    static let tabBarBg = BrandColors.adaptive(
        light: BrandColors.lightSurface.opacity(0.95),
        dark: BrandColors.tealElevated.opacity(0.95)
    )

    /// Tab bar selected icon/text - uses accent for visibility
    static let tabBarSelected = BrandColors.accent

    /// Tab bar unselected icon/text
    static let tabBarUnselected = BrandColors.adaptive(
        light: BrandColors.textDarkSecondary,
        dark: BrandColors.textLight.opacity(0.60)
    )

    // MARK: - Progress Ring Tokens

    /// Progress ring track (background)
    static let progressRingTrack = BrandColors.adaptive(
        light: BrandColors.lightBorder,
        dark: BrandColors.textLight.opacity(0.12)
    )

    /// Progress ring fill (foreground)
    static let progressRingFill = BrandColors.accent

    // MARK: - Status Tokens

    static let success = BrandColors.success
    static let warning = BrandColors.warning
    static let danger = BrandColors.destructive
    static let destructive = BrandColors.destructive
    static let streakFlame = BrandColors.flame

    // MARK: - Shadow Tokens

    static let shadowColor = Color.black.opacity(0.12)
    static let shadowRadius: CGFloat = 8
    static let shadowY: CGFloat = 4

    // MARK: - UIColor Versions (for UIKit APIs)

    static var appBackgroundUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.lightBackgroundUI,
            dark: BrandColors.tealDeepUI
        )
    }

    static var cardBackgroundUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.lightSurfaceUI,
            dark: BrandColors.tealSurfaceUI
        )
    }

    static var surfaceElevatedUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.lightElevatedUI,
            dark: BrandColors.tealElevatedUI
        )
    }

    static var textPrimaryUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.textDarkUI,
            dark: .white
        )
    }

    static var accentUI: UIColor { BrandColors.accentUI }

    static var tabBarSelectedUI: UIColor { BrandColors.accentUI }

    static var tabBarUnselectedUI: UIColor {
        BrandColors.adaptiveUI(
            light: UIColor(BrandColors.textDarkSecondary),
            dark: UIColor.white.withAlphaComponent(0.60)
        )
    }

    static var tabBarBgUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.lightSurfaceUI.withAlphaComponent(0.95),
            dark: BrandColors.tealElevatedUI.withAlphaComponent(0.95)
        )
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
