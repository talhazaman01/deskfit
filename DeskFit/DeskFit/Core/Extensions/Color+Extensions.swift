import SwiftUI
import UIKit

// MARK: - DeskFit Design System (Premium Sky Blue Theme)
// Inspired by Reactive Markets style - clean, technical, calm

extension Color {
    // MARK: - Primary Brand Colors

    /// Primary Sky Blue - main CTAs, key highlights, active states
    /// A premium, calm blue that conveys trust and modernity
    static let appPrimary = Color(light: Color(hex: "0A84FF"), dark: Color(hex: "0A84FF"))

    /// Secondary Deep Navy - headers, emphasis text, outlines on light mode
    static let appSecondary = Color(light: Color(hex: "1C3D5A"), dark: Color(hex: "A8C5E2"))

    /// Tertiary Cool Teal - secondary highlights, success states, PRO badges
    static let tertiary = Color(light: Color(hex: "34C3C0"), dark: Color(hex: "5FD4D1"))

    // MARK: - Backgrounds & Surfaces

    /// Main screen background
    static let background = Color(light: Color(hex: "FAFBFC"), dark: Color(hex: "0D1117"))

    /// Card/container surface
    static let surface = Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "161B22"))

    /// Elevated surface (modals, sheets, popovers)
    static let surfaceElevated = Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "21262D"))

    /// Selected card state - uses appPrimary with opacity for subtle highlight
    static let surfaceSelected = Color(light: Color(hex: "0A84FF").opacity(0.08), dark: Color(hex: "0A84FF").opacity(0.15))

    // MARK: - Text Colors

    /// Primary text - main content
    static let textPrimary = Color(light: Color(hex: "1C2128"), dark: Color(hex: "F0F6FC"))

    /// Secondary text - supporting info
    static let textSecondary = Color(light: Color(hex: "57606A"), dark: Color(hex: "8B949E"))

    /// Tertiary text - placeholders, hints
    static let textTertiary = Color(light: Color(hex: "8B949E"), dark: Color(hex: "6E7681"))

    /// Text on primary colored backgrounds
    static let textOnPrimary = Color.white

    /// Inverted text for dark surfaces in light mode
    static let textOnDark = Color.white

    // MARK: - Button Colors

    /// Primary button background
    static let buttonPrimary = Color.appPrimary

    /// Button text on primary
    static let buttonPrimaryText = Color.white

    /// Disabled button background
    static let buttonDisabled = Color(light: Color(hex: "E1E4E8"), dark: Color(hex: "30363D"))

    /// Disabled button text
    static let buttonDisabledText = Color(light: Color(hex: "8B949E"), dark: Color(hex: "6E7681"))

    // MARK: - Card & Border Colors

    /// Subtle border for cards and dividers
    static let borderSubtle = Color(light: Color(hex: "D0D7DE"), dark: Color(hex: "30363D"))

    /// Selected state border
    static let borderSelected = Color.appPrimary

    /// Divider/separator lines
    static let divider = Color(light: Color(hex: "D8DEE4"), dark: Color(hex: "21262D"))

    // MARK: - Status Colors

    /// Success state
    static let success = Color(light: Color(hex: "1A7F37"), dark: Color(hex: "3FB950"))

    /// Warning state
    static let warning = Color(light: Color(hex: "BF8700"), dark: Color(hex: "D29922"))

    /// Danger/error state
    static let danger = Color(light: Color(hex: "CF222E"), dark: Color(hex: "F85149"))

    /// Info state (uses tertiary)
    static let info = Color.tertiary

    /// Streak flame color
    static let streakFlame = Color(light: Color(hex: "F4A261"), dark: Color(hex: "FFA657"))

    // MARK: - Progress Colors

    /// Progress bar background track
    static let progressBackground = Color(light: Color(hex: "E1E4E8"), dark: Color(hex: "30363D"))

    /// Progress bar fill - uses appPrimary
    static let progressFill = Color.appPrimary

    // MARK: - PRO Badge

    /// PRO badge background
    static let proBadge = Color.tertiary

    /// PRO badge text
    static let proBadgeText = Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "0D1117"))

    // MARK: - Legacy Compatibility (maps old names to new)

    static let appBackground = Color.background
    static let appTeal = Color.appPrimary
    static let appBlack = Color.textPrimary
    static let appCoral = Color.streakFlame
    static let cardBackground = Color.surface
    static let cardSelected = Color.surfaceSelected
    static let buttonEnabled = Color.appPrimary
    static let brandPrimary = Color.appPrimary
    static let brandSecondary = Color.appSecondary
    static let secondaryBackground = Color.surface
    static let accent = Color.appPrimary
}

// MARK: - ShapeStyle Extension for foregroundStyle() support

extension ShapeStyle where Self == Color {
    // Primary palette
    static var appPrimary: Color { Color.appPrimary }
    static var appSecondary: Color { Color.appSecondary }
    static var tertiary: Color { Color.tertiary }

    // Backgrounds
    static var background: Color { Color.background }
    static var surface: Color { Color.surface }
    static var surfaceElevated: Color { Color.surfaceElevated }
    static var surfaceSelected: Color { Color.surfaceSelected }

    // Text
    static var textPrimary: Color { Color.textPrimary }
    static var textSecondary: Color { Color.textSecondary }
    static var textTertiary: Color { Color.textTertiary }
    static var textOnPrimary: Color { Color.textOnPrimary }
    static var textOnDark: Color { Color.textOnDark }

    // Buttons
    static var buttonPrimary: Color { Color.buttonPrimary }
    static var buttonPrimaryText: Color { Color.buttonPrimaryText }
    static var buttonDisabled: Color { Color.buttonDisabled }
    static var buttonDisabledText: Color { Color.buttonDisabledText }

    // Borders
    static var borderSubtle: Color { Color.borderSubtle }
    static var borderSelected: Color { Color.borderSelected }
    static var divider: Color { Color.divider }

    // Status
    static var success: Color { Color.success }
    static var warning: Color { Color.warning }
    static var danger: Color { Color.danger }
    static var info: Color { Color.info }
    static var streakFlame: Color { Color.streakFlame }

    // Progress
    static var progressBackground: Color { Color.progressBackground }
    static var progressFill: Color { Color.progressFill }

    // PRO badge
    static var proBadge: Color { Color.proBadge }
    static var proBadgeText: Color { Color.proBadgeText }

    // Legacy compatibility
    static var appTeal: Color { Color.appTeal }
    static var appCoral: Color { Color.appCoral }
    static var appBlack: Color { Color.appBlack }
    static var appBackground: Color { Color.appBackground }
    static var cardBackground: Color { Color.cardBackground }
    static var cardSelected: Color { Color.cardSelected }
    static var buttonEnabled: Color { Color.buttonEnabled }
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

    /// Creates a color that automatically adapts to light and dark mode
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
