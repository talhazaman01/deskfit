import SwiftUI

/// Premium Sky Blue primary button - full width pill with shadow
struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            guard isEnabled && !isLoading else { return }
            HapticsService.shared.light()
            action()
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.textOnPrimary)
                } else {
                    Text(title)
                        .font(Theme.Typography.button)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Height.primaryButton)
            .background(
                Capsule()
                    .fill(isEnabled ? Color.appPrimary : Color.buttonDisabled)
            )
            .foregroundStyle(isEnabled ? .textOnPrimary : .buttonDisabledText)
            .shadow(
                color: isEnabled ? Color.appPrimary.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(!isEnabled || isLoading)
        .animation(Theme.Animation.quick, value: isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", isEnabled: true) {}
        PrimaryButton(title: "Continue", isEnabled: false) {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
    }
    .padding()
    .background(Color.background)
}
