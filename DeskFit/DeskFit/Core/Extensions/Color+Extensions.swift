import SwiftUI

// MARK: - DeskFit Design System (Celeste Theme)

extension Color {
    // MARK: - Core Palette (From ThemeColor)

    /// Dark blue-teal app background
    static let appBackground = ThemeColor.background

    /// Brand highlight color - Celeste
    static let brandCeleste = ThemeColor.brandCeleste

    /// Primary accent color - cyan
    static let appTeal = ThemeColor.accent

    /// Pure black for compatibility (rarely used)
    static let appBlack = Color.black

    /// Warm coral for accents, streaks, celebrations
    static let appCoral = Color(hex: "E07A5F")

    // MARK: - Text Colors

    static let textPrimary = ThemeColor.textPrimary
    static let textSecondary = ThemeColor.textSecondary
    static let textTertiary = ThemeColor.textTertiary
    static let textOnDark = ThemeColor.textPrimary
    static let textOnAccent = ThemeColor.textOnAccent

    // MARK: - Card & Surface Colors

    /// Surface color for cards/panels
    static let cardBackground = ThemeColor.surface

    /// Selected state - accent with transparency
    static let cardSelected = ThemeColor.accent.opacity(0.2)

    // MARK: - Button Colors

    /// Primary CTA - accent color
    static let buttonPrimary = ThemeColor.accent

    /// Enabled continue button - accent
    static let buttonEnabled = ThemeColor.accent

    /// Disabled button state
    static let buttonDisabled = ThemeColor.surface

    // MARK: - Status Colors

    static let success = ThemeColor.accent
    static let warning = Color(hex: "E07A5F")  // Coral
    static let streakFlame = Color(hex: "F4A261")  // Warm orange

    // MARK: - Progress & Dividers

    static let progressBackground = ThemeColor.surface
    static let progressFill = ThemeColor.accent
    static let divider = ThemeColor.separator

    // MARK: - Legacy Compatibility

    static let brandPrimary = ThemeColor.accent
    static let brandSecondary = appCoral
    static let secondaryBackground = ThemeColor.surface
    static let accent = ThemeColor.accent
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

    static var buttonPrimary: Color { Color.buttonPrimary }
    static var buttonEnabled: Color { Color.buttonEnabled }
    static var buttonDisabled: Color { Color.buttonDisabled }

    static var success: Color { Color.success }
    static var warning: Color { Color.warning }
    static var streakFlame: Color { Color.streakFlame }

    static var progressBackground: Color { Color.progressBackground }
    static var progressFill: Color { Color.progressFill }
    static var divider: Color { Color.divider }

    static var brandPrimary: Color { Color.brandPrimary }
    static var brandSecondary: Color { Color.brandSecondary }
    static var secondaryBackground: Color { Color.secondaryBackground }
    static var accent: Color { Color.accent }
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
