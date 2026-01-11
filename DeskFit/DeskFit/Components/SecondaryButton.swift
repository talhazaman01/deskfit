import SwiftUI

/// Secondary button - outline style with primary color accent
struct SecondaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var style: Style = .outline
    let action: () -> Void

    enum Style {
        case outline
        case text
        case filled
    }

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            HapticsService.shared.light()
            action()
        }) {
            Text(title)
                .font(Theme.Typography.button)
                .frame(maxWidth: style == .text ? nil : .infinity)
                .frame(height: style == .text ? nil : Theme.Height.secondaryButton)
                .foregroundStyle(foregroundColor)
                .background {
                    switch style {
                    case .outline:
                        Capsule()
                            .strokeBorder(isEnabled ? Color.borderSubtle : Color.buttonDisabled, lineWidth: 1.5)
                    case .filled:
                        Capsule()
                            .fill(Color.surface)
                    case .text:
                        EmptyView()
                    }
                }
        }
        .disabled(!isEnabled)
    }

    private var foregroundColor: Color {
        if !isEnabled {
            return .textTertiary
        }
        switch style {
        case .outline, .filled:
            return .textPrimary
        case .text:
            return .primary
        }
    }
}

/// Tertiary/text button for links and minor actions
struct TertiaryButton: View {
    let title: String
    var color: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            Text(title)
                .font(Theme.Typography.subbodyMedium)
                .foregroundStyle(color)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SecondaryButton(title: "Back", style: .outline) {}
        SecondaryButton(title: "Skip", style: .text) {}
        SecondaryButton(title: "Filled", style: .filled) {}
        SecondaryButton(title: "Disabled", isEnabled: false, style: .outline) {}
        TertiaryButton(title: "Privacy Policy") {}
    }
    .padding()
    .background(Color.background)
}
