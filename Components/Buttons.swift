import SwiftUI

struct SecondaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.secondaryBackground)
                .foregroundStyle(isEnabled ? .primary : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isEnabled)
    }
}

struct TextButton: View {
    let title: String
    var color: Color = .brandPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
    }
}

struct IconButton: View {
    let systemName: String
    var size: CGFloat = 24
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
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
        PrimaryButton(title: "Disabled", isEnabled: false) {}
        SecondaryButton(title: "Back") {}
        TextButton(title: "Skip") {}
    }
    .padding()
}
