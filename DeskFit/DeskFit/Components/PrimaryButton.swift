import SwiftUI

/// Cal AI style primary button - full width pill, black when enabled
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
                        .tint(isEnabled ? .textOnAccent : .textTertiary)
                } else {
                    Text(title)
                        .font(Theme.Typography.button)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Height.primaryButton)
            .background(
                Capsule()
                    .fill(isEnabled ? Color.buttonEnabled : Color.buttonDisabled)
            )
            .foregroundStyle(isEnabled ? .textOnAccent : .textTertiary)
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", isEnabled: true) {}
        PrimaryButton(title: "Continue", isEnabled: false) {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
    }
    .padding()
}
