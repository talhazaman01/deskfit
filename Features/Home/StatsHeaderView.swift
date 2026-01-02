import SwiftUI

struct StatsHeaderView: View {
    let profile: UserProfile

    var body: some View {
        HStack(spacing: 24) {
            StatItem(
                icon: "flame.fill",
                value: "\(profile.currentStreak)",
                label: "day streak",
                color: .orange
            )

            Divider()
                .frame(height: 40)

            StatItem(
                icon: "clock.fill",
                value: "\(todayMinutes)",
                label: "min today",
                color: .brandPrimary
            )

            Divider()
                .frame(height: 40)

            StatItem(
                icon: "chart.bar.fill",
                value: "\(profile.totalMinutes)",
                label: "min total",
                color: .success
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryBackground)
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
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
