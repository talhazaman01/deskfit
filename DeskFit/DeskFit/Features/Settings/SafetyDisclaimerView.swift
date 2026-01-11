import SwiftUI

/// A dedicated Safety & Disclaimer screen accessible from Settings.
/// Contains App Store compliant language about the app's intended use.
struct SafetyDisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                headerSection

                movementGuidanceSection

                disclaimerSection

                emergencySection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.vertical, Theme.Spacing.xl)
        }
        .background(Color.appBackground)
        .navigationTitle("Safety & Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "figure.mind.and.body")
                    .font(.system(size: 40))
                    .foregroundStyle(.appTeal)
            }
            .frame(maxWidth: .infinity)

            Text("Move with care")
                .font(Theme.Typography.title)
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, Theme.Spacing.md)
    }

    // MARK: - Movement Guidance

    private var movementGuidanceSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(icon: "hand.raised.fill", title: "Movement Guidance")

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                bulletPoint("Move within your comfortable range of motion")
                bulletPoint("Stop any exercise if you feel pain, numbness, or tingling")
                bulletPoint("Take breaks whenever you need them")
                bulletPoint("Modify exercises to suit your body")
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Disclaimer

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(icon: "info.circle.fill", title: "Important Information")

            Text("DeskFit provides general movement and mobility exercises intended for healthy adults. This app does not provide medical advice, diagnosis, or treatment.")
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)
                .lineSpacing(3)

            Text("If you have any medical conditions, injuries, or concerns about your ability to perform physical activities, please consult with a qualified healthcare professional before using this app.")
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)
                .lineSpacing(3)
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Emergency

    private var emergencySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader(icon: "heart.fill", title: "Your Health Comes First")

            Text("If you experience chest pain, difficulty breathing, or any other concerning symptoms during exercise, stop immediately and seek medical attention.")
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)
                .lineSpacing(3)
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.appTeal)

            Text(title)
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Circle()
                .fill(Color.appTeal)
                .frame(width: 6, height: 6)
                .padding(.top, 7)

            Text(text)
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        SafetyDisclaimerView()
    }
}
