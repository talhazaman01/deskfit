import SwiftUI
import UIKit

// MARK: - DeskFit Semantic Color Tokens
// Single source of truth for all UI colors. All tokens adapt to light/dark mode.

enum AppTheme {
    // MARK: - Background Tokens

    /// Main app background - Celeste tint (light) / Deep navy (dark)
    static let appBackground = BrandColors.adaptive(
        light: BrandColors.celesteTint,
        dark: BrandColors.navyDeep
    )

    /// Card/surface background - White-ish (light) / Navy surface (dark)
    static let cardBackground = BrandColors.adaptive(
        light: Color(hex: "FAFFFE"),  // Subtle Celeste-tinted white
        dark: BrandColors.navySurface
    )

    /// Alternate surface for nested cards - slightly different from cardBackground
    static let surfaceAlt = BrandColors.adaptive(
        light: Color.white,
        dark: Color(hex: "0A3D4F")  // Slightly lighter than navySurface
    )

    // MARK: - Text Tokens

    /// Primary text - Navy ink (light) / White (dark)
    static let textPrimary = BrandColors.adaptive(
        light: BrandColors.navyInk,
        dark: BrandColors.white
    )

    /// Secondary text - Navy at 70% (light) / White at 75% (dark)
    static let textSecondary = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.70),
        dark: BrandColors.white.opacity(0.75)
    )

    /// Tertiary text - Navy at 50% (light) / White at 55% (dark)
    static let textTertiary = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.50),
        dark: BrandColors.white.opacity(0.55)
    )

    /// Text on accent backgrounds (teal buttons, Celeste fills)
    static let textOnAccent = BrandColors.navyInk

    /// Text on primary action buttons
    static let textOnPrimary = BrandColors.navyInk

    // MARK: - Accent & Brand Tokens

    /// Primary accent color - Accent teal
    static let accent = BrandColors.accentTeal

    /// Soft accent for subtle highlights
    static let accentSoft = BrandColors.adaptive(
        light: BrandColors.accentTeal.opacity(0.15),
        dark: BrandColors.accentTeal.opacity(0.20)
    )

    /// Brand Celeste for highlights and branding
    static let brandCeleste = BrandColors.celeste

    // MARK: - Action Button Tokens

    /// Primary CTA background (Start Session, Continue)
    static let primaryActionBg = BrandColors.mintAction

    /// Primary CTA text
    static let primaryActionFg = BrandColors.navyInk

    /// Secondary action stroke color
    static let secondaryActionStroke = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.25),
        dark: BrandColors.white.opacity(0.30)
    )

    /// Secondary action text color
    static let secondaryActionFg = BrandColors.adaptive(
        light: BrandColors.navyInk,
        dark: BrandColors.white
    )

    /// Disabled button background
    static let disabledBg = BrandColors.adaptive(
        light: Color(hex: "E0E0E0"),
        dark: BrandColors.navySurface
    )

    /// Disabled button/text color
    static let disabledFg = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.40),
        dark: BrandColors.white.opacity(0.40)
    )

    // MARK: - Stroke Tokens

    /// Subtle stroke for unselected cards/borders
    static let strokeSubtle = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.12),
        dark: BrandColors.white.opacity(0.12)
    )

    /// Strong stroke for selected/emphasized elements
    static let strokeStrong = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.28),
        dark: BrandColors.accentTeal.opacity(0.65)
    )

    /// Divider/separator color
    static let divider = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.10),
        dark: BrandColors.white.opacity(0.15)
    )

    // MARK: - Selection State Tokens

    /// Selectable card default background (same as cardBackground)
    static let selectableDefault = cardBackground

    /// Selectable card selected fill
    static let selectionFill = BrandColors.adaptive(
        light: BrandColors.celeste.opacity(0.35),
        dark: BrandColors.accentTeal.opacity(0.18)
    )

    /// Selectable card selected stroke
    static let selectionStroke = BrandColors.adaptive(
        light: BrandColors.navyInk,
        dark: BrandColors.accentTeal
    )

    /// Selection checkmark/indicator color
    static let selectionCheck = BrandColors.adaptive(
        light: BrandColors.navyInk,
        dark: BrandColors.accentTeal
    )

    // MARK: - Tab Bar Tokens

    /// Tab bar background
    static let tabBarBg = BrandColors.adaptive(
        light: Color.white.opacity(0.92),
        dark: BrandColors.navySurface.opacity(0.95)
    )

    /// Tab bar selected icon/text
    static let tabBarSelected = BrandColors.adaptive(
        light: BrandColors.navyInk,
        dark: BrandColors.accentTeal
    )

    /// Tab bar unselected icon/text
    static let tabBarUnselected = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.55),
        dark: BrandColors.white.opacity(0.60)
    )

    // MARK: - Progress Ring Tokens

    /// Progress ring track (background)
    static let progressRingTrack = BrandColors.adaptive(
        light: BrandColors.navyInk.opacity(0.10),
        dark: BrandColors.white.opacity(0.12)
    )

    /// Progress ring fill (foreground)
    static let progressRingFill = BrandColors.accentTeal

    // MARK: - Status Tokens

    static let success = BrandColors.mintAction
    static let warning = BrandColors.warning
    static let danger = BrandColors.danger
    static let streakFlame = BrandColors.flame

    // MARK: - Shadow Tokens

    static let shadowColor = Color.black.opacity(0.08)
    static let shadowRadius: CGFloat = 8
    static let shadowY: CGFloat = 4

    // MARK: - UIColor Versions (for UIKit APIs)

    static var appBackgroundUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.celesteTintUI,
            dark: BrandColors.navyDeepUI
        )
    }

    static var cardBackgroundUI: UIColor {
        BrandColors.adaptiveUI(
            light: UIColor(Color(hex: "FAFFFE")),
            dark: BrandColors.navySurfaceUI
        )
    }

    static var textPrimaryUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.navyInkUI,
            dark: .white
        )
    }

    static var accentUI: UIColor { BrandColors.accentTealUI }

    static var tabBarSelectedUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.navyInkUI,
            dark: BrandColors.accentTealUI
        )
    }

    static var tabBarUnselectedUI: UIColor {
        BrandColors.adaptiveUI(
            light: BrandColors.navyInkUI.withAlphaComponent(0.55),
            dark: UIColor.white.withAlphaComponent(0.60)
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
