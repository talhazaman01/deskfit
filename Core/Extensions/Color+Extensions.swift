import SwiftUI

extension Color {
    static let accent = Color("AccentColor")
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)

    // Brand colors - TODO: Define in Assets.xcassets
    static let brandPrimary = Color.blue
    static let brandSecondary = Color.cyan
    static let success = Color.green
    static let warning = Color.orange
}

extension ShapeStyle where Self == Color {
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [.brandPrimary, .brandSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
