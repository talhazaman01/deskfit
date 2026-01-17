import SwiftUI
import UIKit

// MARK: - DeskFit Semantic Color Tokens
// Single source of truth for all UI colors.
// Premium Theme: Blue gradient background + Unified Pink-Coral accents

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

    /// Text on accent backgrounds (white for contrast on coral)
    static let textOnAccent = BrandColors.textOnAccent

    /// Text on primary action buttons (white)
    static let textOnPrimary = BrandColors.textOnAccent

    // MARK: - Primary Accent (CORAL) - CTAs, Selection, Key Highlights

    /// Primary accent color - coral #FF5A7A
    static let accent = BrandColors.primaryCoral

    /// Primary coral for CTAs
    static let primaryCoral = BrandColors.primaryCoral

    /// Coral pressed state
    static let primaryCoralPressed = BrandColors.primaryCoralPressed

    /// Coral subtle tint for backgrounds
    static let primaryCoralTint = BrandColors.primaryCoralTint

    // MARK: - Secondary Accent (Unified with Coral)
    // All accents now use the same pink-coral for consistency

    /// Secondary accent - now coral (unified theme)
    static let accentSecondary = BrandColors.primaryCoral

    /// Coral stroke for outlines (70% opacity)
    static let accentStroke = BrandColors.primaryCoralStroke

    /// Muted accent for subtle highlights (coral)
    static let accentMuted = BrandColors.primaryCoral

    /// Soft accent for subtle highlights (coral tint at 18%)
    static let accentSoft = BrandColors.primaryCoralTint

    /// Accent glow for shadows (coral at 25%)
    static let accentGlow = BrandColors.primaryCoralGlow

    /// Brand highlight - coral
    static let brandCeleste = BrandColors.primaryCoral

    // MARK: - Legacy Teal (Deprecated - mapped to coral)
    /// @available(*, deprecated, message: "Use primaryCoral instead")
    static let secondaryTeal = BrandColors.primaryCoral

    /// @available(*, deprecated, message: "Use primaryCoralTint instead")
    static let secondaryTealTint = BrandColors.primaryCoralTint

    // MARK: - Action Button Tokens

    /// Primary CTA background - coral #FF5A7A
    static let primaryActionBg = BrandColors.primaryCoral

    /// Primary CTA pressed background - darker coral #E94B6C
    static let primaryActionBgPressed = BrandColors.primaryCoralPressed

    /// Primary CTA text - white for contrast
    static let primaryActionFg = BrandColors.textOnAccent

    /// Primary button glow/shadow - coral at 30%
    static let primaryActionGlow = BrandColors.primaryCoralGlow

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

    // MARK: - Selection State Tokens (CORAL - High Contrast)

    /// Selectable card default background (same as cardBackground)
    static let selectableDefault = cardBackground

    /// Selectable card selected fill - coral at 18% opacity
    static let selectionFill = BrandColors.primaryCoralTint

    /// Selectable card selected stroke - coral #FF5A7A
    static let selectionStroke = BrandColors.primaryCoral

    /// Selection checkmark/indicator color - coral
    static let selectionCheck = BrandColors.primaryCoral

    // MARK: - Tab Bar Tokens

    /// Tab bar background - glass effect on gradient
    static let tabBarBg = Color.white.opacity(0.10)

    /// Tab bar selected icon/text - coral for visibility
    static let tabBarSelected = BrandColors.primaryCoral

    /// Tab bar unselected icon/text - white at 60%
    static let tabBarUnselected = Color.white.opacity(0.60)

    // MARK: - Progress Ring Tokens (CORAL)

    /// Progress ring track (background) - white at 15%
    static let progressRingTrack = Color.white.opacity(0.15)

    /// Progress ring fill (foreground) - coral #FF5A7A
    static let progressRingFill = BrandColors.primaryCoral

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

    /// Coral glow shadow for primary buttons
    static let primaryButtonShadow = BrandColors.primaryCoralGlow

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
        BrandColors.primaryCoralUI
    }

    static var primaryCoralUI: UIColor {
        BrandColors.primaryCoralUI
    }

    /// @available(*, deprecated, message: "Use primaryCoralUI instead")
    static var secondaryTealUI: UIColor {
        BrandColors.primaryCoralUI
    }

    static var tabBarSelectedUI: UIColor {
        BrandColors.primaryCoralUI
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

    /// Icon color for selected states (coral)
    static let iconSelected = selectionCheck

    /// Icon color on accent backgrounds (white)
    static let iconOnAccent = textOnAccent
}
