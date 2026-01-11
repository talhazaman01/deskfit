import SwiftUI

/// Text button for minor actions
struct TextButton: View {
    let title: String
    var color: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.subbodyMedium)
                .foregroundStyle(color)
        }
    }
}

/// Icon-only button
struct IconButton: View {
    let systemName: String
    var size: CGFloat = Theme.IconSize.large
    var color: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size))
                .foregroundStyle(color)
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
        PrimaryButton(title: "Disabled", isEnabled: false) {}
        SecondaryButton(title: "Back") {}
        TextButton(title: "Skip") {}
        IconButton(systemName: "gearshape.fill") {}
    }
    .padding()
    .background(Color.background)
}
