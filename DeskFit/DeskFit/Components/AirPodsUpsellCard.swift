import SwiftUI

/// AirPods upsell card with Sky Blue theme
struct AirPodsUpsellCard: View {
    var onEnableAirPods: (() -> Void)?
    var onLearnMore: (() -> Void)?
    var analyticsSource: String = "home"

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header with icon
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "airpodspro")
                    .font(.system(size: Theme.IconSize.medium))
                    .foregroundStyle(.appPrimary)

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
                        .foregroundStyle(.textOnPrimary)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(
                            Capsule()
                                .fill(Color.appPrimary)
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
                            .font(Theme.Typography.subbodyMedium)
                            .foregroundStyle(.appPrimary)
                    }
                }

                Spacer()
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .strokeBorder(Color.borderSubtle, lineWidth: 1)
        )
        .shadow(color: Theme.Shadow.card, radius: Theme.Shadow.cardRadius, x: Theme.Shadow.cardX, y: Theme.Shadow.cardY)
        .onAppear {
            AnalyticsService.shared.track(.airpodsUpsellViewed(source: analyticsSource))
        }
    }
}

/// Compact inline version for settings
struct AirPodsUpsellRow: View {
    var onTap: () -> Void

    var body: some View {
        Button {
            HapticsService.shared.light()
            onTap()
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: "airpodspro")
                    .font(.system(size: Theme.IconSize.medium))
                    .foregroundStyle(.appPrimary)
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
                    .font(.system(size: Theme.IconSize.small, weight: .medium))
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
    .background(Color.background)
}

#Preview("Row") {
    VStack {
        AirPodsUpsellRow(onTap: { print("Row tapped") })
            .padding()
    }
    .background(Color.background)
}
