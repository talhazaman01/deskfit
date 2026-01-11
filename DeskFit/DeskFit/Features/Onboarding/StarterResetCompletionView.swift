import SwiftUI

struct StarterResetCompletionView: View {
    let durationSeconds: Int
    let onUnlockPlans: () -> Void
    let onContinueFree: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Success icon
            ZStack {
                Circle()
                    .fill(Color.success.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark")
                    .font(Theme.Typography.stat)
                    .foregroundStyle(.success)
            }

            Spacer().frame(height: Theme.Spacing.xl)

            // Title
            Text("Great start!")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(.textPrimary)

            Spacer().frame(height: Theme.Spacing.sm)

            // Duration text
            Text("You completed your first \(formattedDuration) reset")
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: Theme.Spacing.xxl)

            // Streak card
            streakCard

            Spacer()

            // CTAs
            ctaSection
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Color.background)
    }

    private var formattedDuration: String {
        if durationSeconds >= 60 {
            let minutes = durationSeconds / 60
            let seconds = durationSeconds % 60
            if seconds == 0 {
                return "\(minutes) min"
            }
            return "\(minutes)m \(seconds)s"
        }
        return "\(durationSeconds)s"
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        HStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.streakFlame.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: "flame.fill")
                    .font(Theme.Typography.statSmall)
                    .foregroundStyle(.streakFlame)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Streak started!")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Text("Day 1 - Keep it going tomorrow")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            Text("1")
                .font(Theme.Typography.statMedium)
                .foregroundStyle(.streakFlame)
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.surface)
        )
    }

    // MARK: - CTA Section

    private var ctaSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Benefit preview
            VStack(spacing: Theme.Spacing.sm) {
                benefitRow(icon: "calendar", text: "Personalized daily plans")
                benefitRow(icon: "bell.badge", text: "Smart reminder scheduling")
                benefitRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed progress tracking")
            }
            .padding(.bottom, Theme.Spacing.md)

            // Primary CTA
            PrimaryButton(title: "Unlock personalized daily plans") {
                onUnlockPlans()
            }

            // Secondary CTA
            Button {
                onContinueFree()
            } label: {
                Text("Continue free")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.vertical, Theme.Spacing.sm)
        }
        .padding(.bottom, Theme.Spacing.bottomArea)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(Theme.Typography.subbody)
                .foregroundStyle(.appPrimary)
                .frame(width: 20)

            Text(text)
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)

            Spacer()
        }
    }
}

#Preview {
    StarterResetCompletionView(
        durationSeconds: 60,
        onUnlockPlans: {},
        onContinueFree: {}
    )
}
