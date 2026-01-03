import SwiftUI

/// Secondary button - outline style or text button
struct SecondaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var style: Style = .outline
    let action: () -> Void

    enum Style {
        case outline
        case text
    }

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            HapticsService.shared.light()
            action()
        }) {
            Text(title)
                .font(Theme.Typography.button)
                .frame(maxWidth: style == .outline ? .infinity : nil)
                .frame(height: style == .outline ? Theme.Height.primaryButton : nil)
                .foregroundStyle(isEnabled ? .textPrimary : .textTertiary)
                .background {
                    if style == .outline {
                        Capsule()
                            .strokeBorder(Color.divider, lineWidth: 1)
                    }
                }
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        SecondaryButton(title: "Back", style: .outline) {}
        SecondaryButton(title: "Skip", style: .text) {}
    }
    .padding()
}
