import SwiftUI
import SwiftData

// MARK: - Progress Tab View

/// Progress tab showing weekly score, 7-day chart, wins, and day-by-day history.
struct ProgressTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var progressStore: ProgressStore
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }
    private var summary: ProgressSummary { progressStore.currentSummary }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                if summary.hasEnoughData {
                    // Weekly Score Ring
                    weeklyScoreSection

                    // 7-Day Progress Chart
                    weeklyChartSection

                    // Streak & Stats
                    statsSection

                    // Wins Section
                    if !summary.wins.isEmpty {
                        winsSection
                    }

                    // Day-by-Day History
                    dayHistorySection
                } else {
                    // New User - Get Started
                    newUserSection
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.bottomArea)
        }
        .background(Color.appBackground)
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            AnalyticsService.shared.track(.progressViewed)
            progressStore.updateSummary()
        }
    }

    // MARK: - Weekly Score Section

    @ViewBuilder
    private var weeklyScoreSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Large animated score ring
            ZStack {
                ProgressRing(
                    progress: summary.scoreProgress,
                    lineWidth: 16,
                    size: 160
                )

                VStack(spacing: 4) {
                    Text("\(summary.weeklyAverageScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.textPrimary)

                    Text("Weekly Avg")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                }
            }
            .padding(.vertical, Theme.Spacing.md)

            // Trend indicator
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: summary.trend.icon)
                    .foregroundStyle(trendColor)
                Text(summary.trend.encouragement)
                    .font(Theme.Typography.body)
                    .foregroundStyle(.textSecondary)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    private var trendColor: Color {
        switch summary.trend {
        case .improving: return .success
        case .neutral: return .textSecondary
        case .declining: return .warning
        }
    }

    // MARK: - Weekly Chart Section

    @ViewBuilder
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("This Week")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            WeeklyChart(entries: summary.last7Days)
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Stats Section

    @ViewBuilder
    private var statsSection: some View {
        HStack(spacing: Theme.Spacing.md) {
            StatCard(
                icon: "flame.fill",
                iconColor: .streakFlame,
                value: summary.streakDisplay,
                label: "Streak"
            )

            StatCard(
                icon: "checkmark.circle.fill",
                iconColor: .success,
                value: summary.sessionsDisplay,
                label: "This Week"
            )

            StatCard(
                icon: "clock.fill",
                iconColor: .appTeal,
                value: summary.minutesDisplay,
                label: "Total Time"
            )
        }
    }

    // MARK: - Wins Section

    @ViewBuilder
    private var winsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Your Wins")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            ForEach(summary.wins) { win in
                WinCard(win: win)
            }
        }
    }

    // MARK: - Day History Section

    @ViewBuilder
    private var dayHistorySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Day by Day")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Spacer()

                if !FeatureGate.isPro {
                    ProBadge()
                }
            }

            ForEach(summary.last7Days.reversed()) { entry in
                DayHistoryRow(entry: entry) {
                    AnalyticsService.shared.track(.progressDayOpened(
                        dayIndex: 0,
                        date: entry.displayDate
                    ))
                }
            }

            // Upgrade prompt for more history
            if !subscriptionManager.isProUser {
                upgradeHistoryPrompt
            }
        }
    }

    @ViewBuilder
    private var upgradeHistoryPrompt: some View {
        Button {
            appState.presentPaywall(source: "progress_history")
            AnalyticsService.shared.track(.upgradeTapped(source: "progress_history"))
        } label: {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.appTeal)
                Text("View full history with Pro")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.textTertiary)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(Color.divider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - New User Section

    @ViewBuilder
    private var newUserSection: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Empty state illustration
            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 64))
                    .foregroundStyle(.textTertiary)

                Text("Start tracking your progress")
                    .font(Theme.Typography.title)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Complete your first session to see your posture score and track your improvement over time.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, Theme.Spacing.xxl)

            // How scoring works
            howScoringWorksCard
        }
    }

    @ViewBuilder
    private var howScoringWorksCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("How Your Score Works")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ScoreFactorRow(icon: "checkmark.circle", text: "Complete sessions to boost your score")
                ScoreFactorRow(icon: "flame", text: "Build streaks for bonus points")
                ScoreFactorRow(icon: "clock", text: "Reset during stiffness times for extra credit")
                ScoreFactorRow(icon: "arrow.up.right", text: "Consistency is key — small resets add up")
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - Weekly Chart

struct WeeklyChart: View {
    let entries: [DailyScoreEntry]

    private var maxScore: Int {
        max(entries.map { $0.score }.max() ?? 100, 100)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
            ForEach(entries) { entry in
                VStack(spacing: Theme.Spacing.xs) {
                    // Bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor(for: entry))
                        .frame(height: barHeight(for: entry))
                        .frame(maxWidth: .infinity)

                    // Day label
                    Text(entry.shortDayName)
                        .font(.system(size: 10))
                        .foregroundStyle(entry.isToday ? .appTeal : .textTertiary)
                }
            }
        }
        .frame(height: 120)
    }

    private func barHeight(for entry: DailyScoreEntry) -> CGFloat {
        guard entry.score > 0 else { return 8 }
        return max(8, CGFloat(entry.score) / CGFloat(maxScore) * 100)
    }

    private func barColor(for entry: DailyScoreEntry) -> Color {
        if !entry.hasActivity {
            return .progressBackground
        } else if entry.isToday {
            return .appTeal
        } else {
            return .appTeal.opacity(0.6)
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)

            Text(value)
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - Win Card

struct WinCard: View {
    let win: ProgressWin

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: win.icon)
                .font(.title2)
                .foregroundStyle(.appTeal)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(win.title)
                    .font(Theme.Typography.body)
                    .foregroundStyle(.textPrimary)

                Text(win.description)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }

            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - Day History Row

struct DayHistoryRow: View {
    let entry: DailyScoreEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                // Date
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.displayDate)
                        .font(Theme.Typography.body)
                        .foregroundStyle(entry.isToday ? .appTeal : .textPrimary)

                    if entry.hasActivity {
                        Text("\(entry.sessionsCompleted) sessions • \(entry.minutesCompleted) min")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textSecondary)
                    } else {
                        Text("No activity")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textTertiary)
                    }
                }

                Spacer()

                // Score
                if entry.hasActivity {
                    Text("\(entry.score)")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)
                } else {
                    Text("—")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textTertiary)
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(.textTertiary)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Score Factor Row

struct ScoreFactorRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(.appTeal)
                .frame(width: 20)

            Text(text)
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview("With Data") {
    NavigationStack {
        ProgressTabView()
    }
    .environmentObject(AppState())
    .environmentObject(SubscriptionManager.shared)
    .environmentObject(ProgressStore.shared)
}
