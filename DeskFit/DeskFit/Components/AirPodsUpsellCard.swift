import SwiftUI

/// A lightweight upsell card for users who don't have AirPods enabled.
/// Shows when `FeatureFlags.shouldShowAirPodsUpsell` is true.
/// This is NOT a paywall - it's an education/conversion card.
struct AirPodsUpsellCard: View {
    /// Called when user taps "I have AirPods"
    var onEnableAirPods: (() -> Void)?

    /// Called when user taps "Learn more"
    var onLearnMore: (() -> Void)?

    /// Source for analytics tracking
    var analyticsSource: String = "home"

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header with icon
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "airpodspro")
                    .font(.system(size: 20))
                    .foregroundStyle(.appTeal)

                Text("Unlock AirPods posture nudges")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Spacer()
            }

            // Description
            Text("Connect AirPods to get gentle reminders that help you stay mindful of your posture.")
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            // Action buttons
            HStack(spacing: Theme.Spacing.md) {
                // Primary CTA
                Button {
                    HapticsService.shared.light()
                    AnalyticsService.shared.track(.airpodsUpsellTapped(action: "enable"))
                    AirPodsCapabilityStore.shared.setOnboardingResponse(.yes)
                    onEnableAirPods?()
                } label: {
                    Text("I have AirPods")
                        .font(Theme.Typography.button)
                        .foregroundStyle(.textOnDark)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(
                            Capsule()
                                .fill(Color.cardSelected)
                        )
                }

                // Secondary CTA
                if onLearnMore != nil {
                    Button {
                        HapticsService.shared.light()
                        AnalyticsService.shared.track(.airpodsUpsellTapped(action: "learn_more"))
                        onLearnMore?()
                    } label: {
                        Text("Learn more")
                            .font(Theme.Typography.button)
                            .foregroundStyle(.textSecondary)
                    }
                }

                Spacer()
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
        .onAppear {
            AnalyticsService.shared.track(.airpodsUpsellViewed(source: analyticsSource))
        }
    }
}

/// A compact inline version for settings or other constrained spaces
struct AirPodsUpsellRow: View {
    var onTap: () -> Void

    var body: some View {
        Button {
            HapticsService.shared.light()
            onTap()
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: "airpodspro")
                    .font(.system(size: 20))
                    .foregroundStyle(.appTeal)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Enable posture nudges")
                        .font(Theme.Typography.option)
                        .foregroundStyle(.textPrimary)

                    Text("Requires AirPods")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.textTertiary)
            }
            .padding(.vertical, Theme.Spacing.md)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Full Card") {
    VStack {
        AirPodsUpsellCard(
            onEnableAirPods: { print("Enable tapped") },
            onLearnMore: { print("Learn more tapped") }
        )
        .padding()
    }
    .background(Color.appBackground)
}

#Preview("Row") {
    VStack {
        AirPodsUpsellRow(onTap: { print("Row tapped") })
            .padding()
    }
    .background(Color.appBackground)
}
