import SwiftUI
import SwiftData

// MARK: - Progress Tab View

/// Progress tab showing weekly score, 7-day chart, wins, and day-by-day history.
struct ProgressTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var entitlementStore: EntitlementStore
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

                VStack(spacing: Theme.Spacing.xs) {
                    Text("\(summary.weeklyAverageScore)")
                        .font(Theme.Typography.stat)
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
                .fill(Color.surface)
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
                .fill(Color.surface)
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
                iconColor: .appPrimary,
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
            if !entitlementStore.isPro {
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
                    .foregroundStyle(.appPrimary)
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
                .fill(Color.surface)
        )
    }
}

// MARK: - Interactive Weekly Chart

struct WeeklyChart: View {
    let entries: [DailyScoreEntry]
    @StateObject private var viewModel = WeeklyChartViewModel()

    private var maxScore: Int {
        max(entries.map { $0.score }.max() ?? 100, 100)
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Tooltip (appears when day is selected)
            tooltipView
                .frame(height: 50)
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedDayIndex)

            // Chart bars
            HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    ChartBar(
                        entry: entry,
                        index: index,
                        isSelected: viewModel.selectedDayIndex == index,
                        maxScore: maxScore,
                        onTap: {
                            // Haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()

                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.toggleSelection(for: index)
                            }
                        }
                    )
                }
            }
            .frame(height: 100)

            // Detail row (appears when day is selected and has activity)
            detailView
                .frame(height: 24)
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedDayIndex)
        }
        .onAppear {
            viewModel.updateEntries(entries)
        }
        .onChange(of: entries) { _, newEntries in
            viewModel.updateEntries(newEntries)
        }
    }

    // MARK: - Tooltip View

    @ViewBuilder
    private var tooltipView: some View {
        if let tooltip = viewModel.selectedDayTooltip {
            VStack(spacing: Theme.Spacing.xs) {
                Text(tooltip)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                if let delta = viewModel.selectedDayDelta {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: delta.isPositive ? "arrow.up.right" : delta.isNegative ? "arrow.down.right" : "minus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(deltaColor(for: delta))

                        Text(delta.displayText)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(deltaColor(for: delta))
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Color.surface)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .transition(.scale.combined(with: .opacity))
        } else {
            // Empty state hint
            Text("Tap a day to see details")
                .font(Theme.Typography.caption)
                .foregroundStyle(.textTertiary)
        }
    }

    // MARK: - Detail View

    @ViewBuilder
    private var detailView: some View {
        if let detail = viewModel.selectedDayDetail {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.success)

                Text(detail)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)

                if let streak = viewModel.selectedDayStreak, streak > 1 {
                    Spacer()

                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.streakFlame)

                        Text("\(streak) day streak")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
            .transition(.opacity)
        }
    }

    // MARK: - Helpers

    private func deltaColor(for delta: DeltaInfo) -> Color {
        if delta.isPositive {
            return .success
        } else if delta.isNegative {
            return .warning
        } else {
            return .textSecondary
        }
    }
}

// MARK: - Chart Bar

private struct ChartBar: View {
    let entry: DailyScoreEntry
    let index: Int
    let isSelected: Bool
    let maxScore: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.xs) {
                // Bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(height: barHeight)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(x: isSelected ? 1.15 : 1.0, y: 1.0, anchor: .bottom)
                    .shadow(
                        color: isSelected ? barColor.opacity(0.4) : .clear,
                        radius: isSelected ? 4 : 0,
                        x: 0,
                        y: 2
                    )

                // Day label
                Text(entry.shortDayName)
                    .font(isSelected ? Theme.Typography.captionMedium : Theme.Typography.micro)
                    .foregroundStyle(labelColor)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var barHeight: CGFloat {
        guard entry.score > 0 else { return 8 }
        return max(8, CGFloat(entry.score) / CGFloat(maxScore) * 80)
    }

    private var barColor: Color {
        if !entry.hasActivity {
            return .progressBackground
        } else if isSelected {
            return .appPrimary
        } else if entry.isToday {
            return .appPrimary
        } else {
            return .appPrimary.opacity(0.6)
        }
    }

    private var labelColor: Color {
        if isSelected {
            return .appPrimary
        } else if entry.isToday {
            return .appPrimary
        } else {
            return .textTertiary
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
                .fill(Color.surface)
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
                .foregroundStyle(.appPrimary)
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
                .fill(Color.surface)
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
                        .foregroundStyle(entry.isToday ? .appPrimary : .textPrimary)

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
                    .fill(Color.surface)
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
                .foregroundStyle(.appPrimary)
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
