import SwiftUI

struct StatsHeaderView: View {
    let profile: UserProfile

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
                color: .appTeal
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
                .fill(Color.cardBackground)
        )
    }

    private var todayMinutes: Int {
        // TODO: Calculate from today's completed sessions
        0
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
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.textPrimary)
            }

            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
        }
    }
}
