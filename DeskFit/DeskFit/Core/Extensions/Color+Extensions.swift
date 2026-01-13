import SwiftUI

// MARK: - DeskFit Design System (Teal Theme)
// Color extensions that bridge to AppTheme tokens for backward compatibility.

extension Color {
    // MARK: - Core Palette (From AppTheme)

    /// App background - adapts to light/dark mode
    static let appBackground = AppTheme.appBackground

    /// Brand highlight color - now accent teal
    static let brandCeleste = AppTheme.brandCeleste

    /// Primary accent color - bright teal
    static let appTeal = AppTheme.accent

    /// Pure black for compatibility
    static let appBlack = Color.black

    /// Warm coral for accents, streaks, celebrations
    static let appCoral = BrandColors.flame

    // MARK: - Text Colors

    static let textPrimary = AppTheme.textPrimary
    static let textSecondary = AppTheme.textSecondary
    static let textTertiary = AppTheme.textTertiary
    static let textOnDark = BrandColors.textDark
    static let textOnAccent = AppTheme.textOnAccent

    // MARK: - Card & Surface Colors

    /// Surface color for cards/panels
    static let cardBackground = AppTheme.cardBackground

    /// Selected state background
    static let cardSelected = AppTheme.selectionFill

    /// Selected state with higher visibility (for chips/badges)
    static let cardSelectedStrong = AppTheme.accentSoft

    /// Elevated surface for modals/sheets
    static let surfaceElevated = AppTheme.surfaceElevated

    // MARK: - Border Colors

    /// Default border for unselected cards - subtle
    static let borderDefault = AppTheme.strokeSubtle

    /// Selected border - prominent
    static let borderSelected = AppTheme.selectionStroke

    /// Theme border color
    static let border = AppTheme.border

    // MARK: - Button Colors

    /// Primary CTA - accent teal
    static let buttonPrimary = AppTheme.primaryActionBg

    /// Enabled continue button
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

    static let brandPrimary = AppTheme.accent
    static let brandSecondary = appCoral
    static let secondaryBackground = AppTheme.cardBackground
    static let accent = AppTheme.accent
    static let accentMuted = AppTheme.accentMuted
}

// MARK: - ShapeStyle Extension for foregroundStyle() support

extension ShapeStyle where Self == Color {
    static var appTeal: Color { Color.appTeal }
    static var appCoral: Color { Color.appCoral }
    static var appBlack: Color { Color.appBlack }
    static var appBackground: Color { Color.appBackground }
    static var brandCeleste: Color { Color.brandCeleste }

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
    static var accent: Color { Color.accent }
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
