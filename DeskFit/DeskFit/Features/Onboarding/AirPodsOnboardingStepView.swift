import SwiftUI

/// Onboarding step asking the user if they have AirPods.
/// Includes detection hints but never forces an answer based on detection.
struct AirPodsOnboardingStepView: View {
    @Binding var selectedResponse: AirPodsOnboardingResponse?
    @ObservedObject var detectionService = AirPodsDetectionService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Do you have AirPods?")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(.textPrimary)

                Text("This lets us enable gentle posture nudges through your headphones.")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.lg)

            // Detection hint (if headphones detected)
            if detectionService.isHeadphoneDetected {
                detectionHintBanner
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.bottom, Theme.Spacing.lg)
            }

            Spacer()

            // Options
            VStack(spacing: Theme.Spacing.md) {
                OptionCard(
                    title: "Yes, I have AirPods",
                    subtitle: "Enable posture nudges",
                    icon: "airpodspro",
                    isSelected: selectedResponse == .yes
                ) {
                    withAnimation(Theme.Animation.spring) {
                        selectedResponse = .yes
                    }
                }

                OptionCard(
                    title: "No, I don't have AirPods",
                    subtitle: "Skip posture nudges for now",
                    icon: "headphones",
                    isSelected: selectedResponse == .no
                ) {
                    withAnimation(Theme.Animation.spring) {
                        selectedResponse = .no
                    }
                }

                // "Not sure" as a subtle text button
                Button {
                    HapticsService.shared.light()
                    withAnimation(Theme.Animation.spring) {
                        selectedResponse = .notSure
                    }
                } label: {
                    Text("Not sure")
                        .font(Theme.Typography.subtitle)
                        .foregroundStyle(selectedResponse == .notSure ? .textPrimary : .textSecondary)
                        .underline(selectedResponse == .notSure)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            // Microcopy for users without headphones connected
            if !detectionService.isHeadphoneDetected {
                notConnectedHint
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.top, Theme.Spacing.lg)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            AnalyticsService.shared.track(.onboardingAirpodsQuestionViewed)
        }
    }

    // MARK: - Subviews

    /// Banner shown when headphones are detected
    private var detectionHintBanner: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.appTeal)
                .font(.system(size: 16))

            Text("We detected headphones connected")
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)

            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Color.appTeal.opacity(0.1))
        )
    }

    /// Hint text for when no headphones are detected
    private var notConnectedHint: some View {
        Text("Even if they're not connected right now, you can still choose Yes.")
            .font(Theme.Typography.caption)
            .foregroundStyle(.textTertiary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

#Preview("No Detection") {
    AirPodsOnboardingStepView(selectedResponse: .constant(nil))
}

#Preview("Yes Selected") {
    AirPodsOnboardingStepView(selectedResponse: .constant(.yes))
}

#Preview("No Selected") {
    AirPodsOnboardingStepView(selectedResponse: .constant(.no))
}
