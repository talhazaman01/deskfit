import SwiftUI

// MARK: - DeskFit Design System (Hybrid: Cal AI layout + Wellness colors)

extension Color {
    // MARK: - Core Palette

    /// Pure white background - clean, minimalist
    static let appBackground = Color.white

    /// Primary brand color - calming teal for wellness
    static let appTeal = Color(hex: "2A9D8F")

    /// Pure black for selected states and strong emphasis
    static let appBlack = Color.black

    /// Warm coral for accents, streaks, celebrations
    static let appCoral = Color(hex: "E07A5F")

    // MARK: - Text Colors

    static let textPrimary = Color.black
    static let textSecondary = Color(hex: "666666")
    static let textTertiary = Color(hex: "999999")
    static let textOnDark = Color.white

    // MARK: - Card & Surface Colors

    /// Light gray for unselected cards/options
    static let cardBackground = Color(hex: "F5F5F5")

    /// Black fill for selected state (Cal AI style)
    static let cardSelected = Color.black

    // MARK: - Button Colors

    /// Primary CTA - teal for wellness actions
    static let buttonPrimary = Color(hex: "2A9D8F")

    /// Enabled continue button - black (Cal AI style)
    static let buttonEnabled = Color.black

    /// Disabled button state
    static let buttonDisabled = Color(hex: "CCCCCC")

    // MARK: - Status Colors

    static let success = Color(hex: "2A9D8F")  // Teal
    static let warning = Color(hex: "E07A5F")  // Coral
    static let streakFlame = Color(hex: "F4A261")  // Warm orange

    // MARK: - Progress & Dividers

    static let progressBackground = Color(hex: "E5E5E5")
    static let progressFill = Color.black
    static let divider = Color(hex: "EEEEEE")

    // MARK: - Legacy Compatibility

    static let brandPrimary = appTeal
    static let brandSecondary = appCoral
    static let secondaryBackground = cardBackground
    static let accent = appTeal
}

// MARK: - ShapeStyle Extension for foregroundStyle() support

extension ShapeStyle where Self == Color {
    static var appTeal: Color { Color.appTeal }
    static var appCoral: Color { Color.appCoral }
    static var appBlack: Color { Color.appBlack }
    static var appBackground: Color { Color.appBackground }

    static var textPrimary: Color { Color.textPrimary }
    static var textSecondary: Color { Color.textSecondary }
    static var textTertiary: Color { Color.textTertiary }
    static var textOnDark: Color { Color.textOnDark }

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
