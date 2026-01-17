import SwiftUI

// MARK: - DeskFit Design System (Premium Pink-Coral Theme)
// Color extensions that bridge to AppTheme tokens for backward compatibility.

extension Color {
    // MARK: - Core Palette (From AppTheme)

    /// App background - blue gradient mid color (fallback for non-gradient usage)
    static let appBackground = AppTheme.appBackground

    /// Brand highlight color - pink-coral primary accent
    static let brandCeleste = AppTheme.brandCeleste

    /// Primary accent color - coral #FF5A7A (for selection, CTAs, progress)
    static let appCoral = AppTheme.primaryCoral

    /// Accent stroke for outlines - coral at 70% opacity
    static let accentStroke = AppTheme.accentStroke

    /// Accent glow for shadows - coral at 25% opacity
    static let accentGlow = AppTheme.accentGlow

    /// @available(*, deprecated, message: "Use appCoral instead - teal accent removed")
    static let appTeal = AppTheme.primaryCoral

    /// Pure black for compatibility
    static let appBlack = Color.black

    // MARK: - Text Colors

    static let textPrimary = AppTheme.textPrimary
    static let textSecondary = AppTheme.textSecondary
    static let textTertiary = AppTheme.textTertiary
    static let textOnDark = AppTheme.textOnAccent
    static let textOnAccent = AppTheme.textOnAccent

    // MARK: - Card & Surface Colors

    /// Surface color for cards/panels - glass effect
    static let cardBackground = AppTheme.cardBackground

    /// Selected state background - coral tint
    static let cardSelected = AppTheme.selectionFill

    /// Selected state with higher visibility (for chips/badges) - coral tint
    static let cardSelectedStrong = AppTheme.accentSoft

    /// Elevated surface for modals/sheets
    static let surfaceElevated = AppTheme.surfaceElevated

    // MARK: - Border Colors

    /// Default border for unselected cards - subtle
    static let borderDefault = AppTheme.strokeSubtle

    /// Selected border - coral #FF5A7A
    static let borderSelected = AppTheme.selectionStroke

    /// Theme border color
    static let border = AppTheme.border

    // MARK: - Button Colors

    /// Primary CTA - coral #FF5A7A
    static let buttonPrimary = AppTheme.primaryActionBg

    /// Enabled continue button - coral
    static let buttonEnabled = AppTheme.primaryActionBg

    /// Disabled button state
    static let buttonDisabled = AppTheme.disabledBg

    // MARK: - Status Colors

    static let success = AppTheme.success
    static let warning = AppTheme.warning
    static let danger = AppTheme.danger
    static let destructive = AppTheme.destructive
    static let streakFlame = AppTheme.streakFlame

    // MARK: - Progress & Dividers

    static let progressBackground = AppTheme.progressRingTrack
    static let progressFill = AppTheme.progressRingFill
    static let divider = AppTheme.divider

    // MARK: - Legacy Compatibility

    /// Primary brand color - coral (formerly cyan)
    static let brandPrimary = AppTheme.accent

    /// Secondary brand color - coral
    static let brandSecondary = appCoral

    static let secondaryBackground = AppTheme.cardBackground

    // Note: `accent` removed to avoid conflict with Xcode's auto-generated AccentColor asset symbol.
    // Use `appCoral` or `brandPrimary` instead.

    /// Muted accent - now coral (unified theme)
    static let accentMuted = AppTheme.accentMuted

    /// Soft accent - coral at 18% opacity
    static let accentSoft = AppTheme.accentSoft
}

// MARK: - ShapeStyle Extension for foregroundStyle() support

extension ShapeStyle where Self == Color {
    /// @available(*, deprecated, message: "Use appCoral instead - teal accent removed")
    static var appTeal: Color { Color.appCoral }
    static var appCoral: Color { Color.appCoral }
    static var appBlack: Color { Color.appBlack }
    static var appBackground: Color { Color.appBackground }
    static var brandCeleste: Color { Color.brandCeleste }
    static var accentStroke: Color { Color.accentStroke }
    static var accentGlow: Color { Color.accentGlow }
    static var accentSoft: Color { Color.accentSoft }

    static var textPrimary: Color { Color.textPrimary }
    static var textSecondary: Color { Color.textSecondary }
    static var textTertiary: Color { Color.textTertiary }
    static var textOnDark: Color { Color.textOnDark }
    static var textOnAccent: Color { Color.textOnAccent }

    static var cardBackground: Color { Color.cardBackground }
    static var cardSelected: Color { Color.cardSelected }
    static var cardSelectedStrong: Color { Color.cardSelectedStrong }
    static var surfaceElevated: Color { Color.surfaceElevated }
    static var borderDefault: Color { Color.borderDefault }
    static var borderSelected: Color { Color.borderSelected }
    static var border: Color { Color.border }

    static var buttonPrimary: Color { Color.buttonPrimary }
    static var buttonEnabled: Color { Color.buttonEnabled }
    static var buttonDisabled: Color { Color.buttonDisabled }

    static var success: Color { Color.success }
    static var warning: Color { Color.warning }
    static var danger: Color { Color.danger }
    static var destructive: Color { Color.destructive }
    static var streakFlame: Color { Color.streakFlame }

    static var progressBackground: Color { Color.progressBackground }
    static var progressFill: Color { Color.progressFill }
    static var divider: Color { Color.divider }

    static var brandPrimary: Color { Color.brandPrimary }
    static var brandSecondary: Color { Color.brandSecondary }
    static var secondaryBackground: Color { Color.secondaryBackground }
    static var accentMuted: Color { Color.accentMuted }
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
