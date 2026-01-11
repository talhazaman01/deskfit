import SwiftUI
import UIKit

// MARK: - DeskFit Theme Constants

enum Theme {
    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32

        /// Horizontal screen padding
        static let screenHorizontal: CGFloat = 20

        /// Vertical padding for bottom CTA area
        static let bottomArea: CGFloat = 34
    }

    // MARK: - Corner Radius

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20

        /// Pill button radius
        static let pill: CGFloat = 28
    }

    // MARK: - Typography (Montserrat)

    enum Typography {
        // Font names
        private static let regular = "Montserrat-Regular"
        private static let medium = "Montserrat-Medium"
        private static let semiBold = "Montserrat-SemiBold"
        private static let bold = "Montserrat-Bold"

        /// Display text - 34pt bold (hero numbers, large stats)
        static let display = montserrat(size: 34, weight: .bold)

        /// Title 1 - 28pt semibold (screen titles)
        static let title1 = montserrat(size: 28, weight: .semibold)

        /// Title 2 - 22pt semibold (section headers)
        static let title2 = montserrat(size: 22, weight: .semibold)

        /// Large title for onboarding questions - 28pt bold
        static let largeTitle = montserrat(size: 28, weight: .bold)

        /// Screen titles - 24pt bold
        static let title = montserrat(size: 24, weight: .bold)

        /// Section headers - 18pt semibold
        static let headline = montserrat(size: 18, weight: .semibold)

        /// Body text - 16pt regular
        static let body = montserrat(size: 16, weight: .regular)

        /// Body text emphasized - 16pt medium
        static let bodyMedium = montserrat(size: 16, weight: .medium)

        /// Subtitle/description text - 15pt regular
        static let subtitle = montserrat(size: 15, weight: .regular)

        /// Subtitle medium weight - 15pt medium
        static let subtitleMedium = montserrat(size: 15, weight: .medium)

        /// Sub-body text - 14pt regular
        static let subbody = montserrat(size: 14, weight: .regular)

        /// Sub-body text medium - 14pt medium
        static let subbodyMedium = montserrat(size: 14, weight: .medium)

        /// Small labels/captions - 12pt regular
        static let caption = montserrat(size: 12, weight: .regular)

        /// Caption medium weight - 12pt medium
        static let captionMedium = montserrat(size: 12, weight: .medium)

        /// Extra small text - 10pt semibold (badges, pills)
        static let micro = montserrat(size: 10, weight: .semibold)

        /// Button text - 17pt semibold
        static let button = montserrat(size: 17, weight: .semibold)

        /// Card option text - 17pt medium
        static let option = montserrat(size: 17, weight: .medium)

        /// Card description text - 13pt regular
        static let optionDescription = montserrat(size: 13, weight: .regular)

        /// Stats/numbers - 48pt bold
        static let stat = montserrat(size: 48, weight: .bold)

        /// Medium stats - 32pt bold
        static let statMedium = montserrat(size: 32, weight: .bold)

        /// Small stats - 24pt bold
        static let statSmall = montserrat(size: 24, weight: .bold)

        /// Navigation title - 17pt semibold
        static let navTitle = montserrat(size: 17, weight: .semibold)

        /// Tab bar label - 10pt medium
        static let tabLabel = montserrat(size: 10, weight: .medium)

        // MARK: - Font Builder

        enum FontWeight {
            case regular
            case medium
            case semibold
            case bold
        }

        /// Creates a Montserrat font with fallback to system font
        static func montserrat(size: CGFloat, weight: FontWeight) -> Font {
            let fontName: String
            let uiWeight: UIFont.Weight

            switch weight {
            case .regular:
                fontName = regular
                uiWeight = .regular
            case .medium:
                fontName = medium
                uiWeight = .medium
            case .semibold:
                fontName = semiBold
                uiWeight = .semibold
            case .bold:
                fontName = bold
                uiWeight = .bold
            }

            // Try to load custom font, fallback to system if not available
            if let _ = UIFont(name: fontName, size: size) {
                return Font.custom(fontName, size: size)
            } else {
                return Font.system(size: size, weight: swiftUIWeight(from: uiWeight))
            }
        }

        /// Creates a Montserrat UIFont with fallback to system font
        static func uiFont(size: CGFloat, weight: FontWeight) -> UIFont {
            let fontName: String
            let uiWeight: UIFont.Weight

            switch weight {
            case .regular:
                fontName = regular
                uiWeight = .regular
            case .medium:
                fontName = medium
                uiWeight = .medium
            case .semibold:
                fontName = semiBold
                uiWeight = .semibold
            case .bold:
                fontName = bold
                uiWeight = .bold
            }

            return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: uiWeight)
        }

        private static func swiftUIWeight(from uiWeight: UIFont.Weight) -> Font.Weight {
            switch uiWeight {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            default: return .regular
            }
        }
    }

    // MARK: - Shadows

    enum Shadow {
        static let card = SwiftUI.Color.black.opacity(0.08)
        static let cardRadius: CGFloat = 12
        static let cardX: CGFloat = 0
        static let cardY: CGFloat = 2

        static let elevated = SwiftUI.Color.black.opacity(0.12)
        static let elevatedRadius: CGFloat = 16
    }

    // MARK: - Animation

    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)
    }

    // MARK: - Component Heights

    enum Height {
        static let optionCard: CGFloat = 56
        static let optionCardWithDescription: CGFloat = 72
        static let primaryButton: CGFloat = 56
        static let secondaryButton: CGFloat = 48
        static let progressBar: CGFloat = 4
        static let tabBar: CGFloat = 49
        static let navBar: CGFloat = 44
    }

    // MARK: - Icon Sizes

    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let hero: CGFloat = 48
    }
}

// MARK: - View Modifiers

extension View {
    /// Apply standard screen padding
    func screenPadding() -> some View {
        self.padding(.horizontal, Theme.Spacing.screenHorizontal)
    }

    /// Apply card style with surface background and subtle shadow
    func cardStyle(isSelected: Bool = false) -> some View {
        self
            .padding(Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isSelected ? Color.surfaceSelected : Color.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .strokeBorder(isSelected ? Color.borderSelected : Color.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Theme.Shadow.card, radius: Theme.Shadow.cardRadius, x: Theme.Shadow.cardX, y: Theme.Shadow.cardY)
    }

    /// Apply elevated card style for modals/sheets
    func elevatedCardStyle() -> some View {
        self
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.surfaceElevated)
            )
            .shadow(color: Theme.Shadow.elevated, radius: Theme.Shadow.elevatedRadius)
    }

    /// Apply background with brand background color
    func brandBackground() -> some View {
        self.background(Color.background.ignoresSafeArea())
    }
}

// MARK: - Font Extension for Brand Typography

extension Font {
    /// Creates a Montserrat font using the brand typography system
    static func brand(_ style: BrandFontStyle) -> Font {
        switch style {
        case .display:
            return Theme.Typography.display
        case .title1:
            return Theme.Typography.title1
        case .title2:
            return Theme.Typography.title2
        case .headline:
            return Theme.Typography.headline
        case .body:
            return Theme.Typography.body
        case .bodyMedium:
            return Theme.Typography.bodyMedium
        case .subtitle:
            return Theme.Typography.subtitle
        case .subbody:
            return Theme.Typography.subbody
        case .subbodyMedium:
            return Theme.Typography.subbodyMedium
        case .caption:
            return Theme.Typography.caption
        case .captionMedium:
            return Theme.Typography.captionMedium
        case .micro:
            return Theme.Typography.micro
        case .button:
            return Theme.Typography.button
        case .stat:
            return Theme.Typography.stat
        case .statMedium:
            return Theme.Typography.statMedium
        case .statSmall:
            return Theme.Typography.statSmall
        }
    }
}

enum BrandFontStyle {
    case display
    case title1
    case title2
    case headline
    case body
    case bodyMedium
    case subtitle
    case subbody
    case subbodyMedium
    case caption
    case captionMedium
    case micro
    case button
    case stat
    case statMedium
    case statSmall
}
