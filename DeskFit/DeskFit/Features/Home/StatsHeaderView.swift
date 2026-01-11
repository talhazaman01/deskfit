import SwiftUI

struct StatsHeaderView: View {
    let profile: UserProfile
    let todayMinutes: Int

    var body: some View {
        HStack(spacing: 0) {
            StatItem(
                icon: "flame.fill",
                value: "\(profile.currentStreak)",
                label: "day streak",
                color: .streakFlame
            )

            Spacer()

            Divider()
                .frame(height: 40)

            Spacer()

            StatItem(
                icon: "clock.fill",
                value: "\(todayMinutes)",
                label: "min today",
                color: .primary
            )

            Spacer()

            Divider()
                .frame(height: 40)

            Spacer()

            StatItem(
                icon: "chart.bar.fill",
                value: "\(profile.totalMinutes)",
                label: "min total",
                color: .success
            )
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.surface)
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: icon)
                    .foregroundStyle(color)

                Text(value)
                    .font(Theme.Typography.statSmall)
                    .foregroundStyle(.textPrimary)
            }

            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
        }
    }
}
