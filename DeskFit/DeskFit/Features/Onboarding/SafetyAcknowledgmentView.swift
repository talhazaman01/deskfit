import SwiftUI

/// A friendly safety acknowledgment screen shown once during onboarding,
/// right before the starter reset session. Non-alarming, App Store compliant.
struct SafetyAcknowledgmentView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            contentSection

            Spacer()

            buttonSection
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Color.appBackground)
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Friendly icon
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "figure.mind.and.body")
                    .font(.system(size: 50))
                    .foregroundStyle(.appTeal)
            }

            // Title
            Text("Move comfortably")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)

            // Body text - friendly, non-scary, App Store compliant
            Text("These are gentle mobility exercises. Move within a comfortable range and stop if you feel pain, numbness, or tingling. This app is not medical advice.")
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, Theme.Spacing.md)
        }
    }

    // MARK: - Buttons

    private var buttonSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            PrimaryButton(title: "I Understand") {
                AnalyticsService.shared.track(.onboardingSafetyAcknowledged(action: "accepted"))
                onContinue()
            }

            Button {
                AnalyticsService.shared.track(.onboardingSafetyAcknowledged(action: "skipped"))
                onSkip()
            } label: {
                Text("Skip")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.bottom, Theme.Spacing.sm)
        }
        .padding(.bottom, Theme.Spacing.bottomArea)
    }
}

#Preview {
    SafetyAcknowledgmentView(
        onContinue: {},
        onSkip: {}
    )
}
