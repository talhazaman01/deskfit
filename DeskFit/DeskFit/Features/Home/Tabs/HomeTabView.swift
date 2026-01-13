import SwiftUI
import SwiftData
import Combine

// MARK: - Home Tab View

/// Main home tab with daily focus, score, next session, and personalized insights.
struct HomeTabView: View {
    @ObservedObject var sessionCoordinator: HomeSessionCoordinator

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var progressStore: ProgressStore
    @Query private var profiles: [UserProfile]
    @Query private var weeklyPlans: [WeeklyPlan]

    @StateObject private var viewModel = HomeTabViewModel()

    private var profile: UserProfile? { profiles.first }

    private var currentWeeklyPlan: WeeklyPlan? {
        weeklyPlans.first { plan in
            let calendar = Calendar.current
            let weekStart = plan.weekStartDate
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            return Date() >= weekStart && Date() <= weekEnd
        }
    }

    private var todaysPlan: DayPlanItem? {
        currentWeeklyPlan?.todaysPlan()
    }

    private var todayDayIndex: Int {
        guard let plan = currentWeeklyPlan else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: plan.weekStartDate, to: Date()).day ?? 0
    }

    private var nextIncompleteSession: MicroSession? {
        todaysPlan?.sessions.first(where: { !$0.isCompleted })
    }

    private var nextSessionIndex: Int {
        guard let plan = todaysPlan, let session = nextIncompleteSession else { return 0 }
        return plan.sessions.firstIndex(where: { $0.id == session.id }) ?? 0
    }

    private var isNextSessionLocked: Bool {
        !FeatureGate.canAccessSession(sessionIndex: nextSessionIndex, forDayIndex: todayDayIndex)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Greeting + Status
                greetingSection

                // Today's Score
                todayScoreSection

                // Next Session Card
                nextSessionSection

                // Smart Nudges (Pro feature teaser for free users)
                smartNudgesSection

                // Personalized Insight
                if let insight = viewModel.todayInsight {
                    insightCard(insight)
                }

                // Upgrade Card (free users only)
                if !subscriptionManager.isProUser {
                    upgradeCard
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.bottomArea)
        }
        .deskFitScreenBackground()
        .navigationTitle("DeskFit")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.navigateTo(.settings)
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.textPrimary)
                }
            }
        }
        .onAppear {
            viewModel.loadData(profile: profile, progressStore: progressStore)
            if let profile = profile {
                StreakService.shared.checkAndResetStreak(for: profile, context: modelContext)
            }
            handleAutoStartIfNeeded()
        }
        .onChange(of: appState.shouldStartNextSession) { _, shouldStart in
            if shouldStart {
                appState.shouldStartNextSession = false
                startNextSession()
            }
        }
    }

    // MARK: - Greeting Section

    @ViewBuilder
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(viewModel.greeting)
                .font(Theme.Typography.headline)
                .foregroundStyle(.textSecondary)

            if let focus = viewModel.todayFocus {
                Text("Today's focus: \(focus)")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Today's Score Section

    @ViewBuilder
    private var todayScoreSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack(alignment: .center, spacing: Theme.Spacing.lg) {
                // Score Ring
                ZStack {
                    ProgressRing(
                        progress: Double(viewModel.todayScore) / 100.0,
                        lineWidth: 10,
                        size: 80
                    )

                    VStack(spacing: 0) {
                        Text("\(viewModel.todayScore)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.textPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Posture Score")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    Text(viewModel.scoreCategory.encouragement)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)

                    if let streak = profile?.currentStreak, streak > 0 {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundStyle(.streakFlame)
                            Text("\(streak) day streak")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.textSecondary)
                        }
                    }
                }

                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.cardBackground)
            )
        }
    }

    // MARK: - Next Session Section

    @ViewBuilder
    private var nextSessionSection: some View {
        if let nextSession = nextIncompleteSession {
            NextSessionCard(
                session: nextSession,
                isLocked: isNextSessionLocked,
                onStart: {
                    if isNextSessionLocked {
                        appState.presentPaywall(source: "home_next_session")
                        AnalyticsService.shared.track(.upgradeTapped(source: "home_next_session"))
                    } else {
                        startSession(nextSession)
                    }
                }
            )
        } else if todaysPlan?.isFullyCompleted == true {
            completedBadge
        } else {
            // Loading or generating plan
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 100)
                .onAppear {
                    generatePlanIfNeeded()
                }
        }
    }

    @ViewBuilder
    private var completedBadge: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.success)

            Text("All done for today!")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            Text("Great job keeping up with your resets")
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Smart Nudges Section

    @ViewBuilder
    private var smartNudgesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundStyle(.appTeal)
                Text("Smart Nudges")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)
                Spacer()

                if !FeatureGate.isPro {
                    ProBadge()
                }
            }

            if FeatureGate.isPro {
                // Pro users see actual nudge info
                if let nextReminder = viewModel.nextReminderTime {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "clock")
                            .foregroundStyle(.textSecondary)
                        Text("Next reminder at \(nextReminder)")
                            .font(Theme.Typography.body)
                            .foregroundStyle(.textSecondary)
                    }
                } else {
                    Button {
                        appState.navigateTo(.reminders)
                    } label: {
                        Text("Set up smart reminders")
                            .font(Theme.Typography.body)
                            .foregroundStyle(.appTeal)
                    }
                }
            } else {
                // Free users see teaser
                Text("Get reminded at the right moment based on your stiffness patterns")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)

                Button {
                    appState.presentPaywall(source: "smart_nudges_teaser")
                    AnalyticsService.shared.track(.upgradeTapped(source: "smart_nudges_teaser"))
                } label: {
                    Text("Unlock with Pro")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.appTeal)
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Insight Card

    @ViewBuilder
    private func insightCard(_ insight: InsightCard) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: insight.icon)
                    .foregroundStyle(.appTeal)
                Text("Today's Insight")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)
            }

            Text(insight.title)
                .font(Theme.Typography.body)
                .foregroundStyle(.textPrimary)

            Text(insight.body)
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
                .lineLimit(3)
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Upgrade Card

    @ViewBuilder
    private var upgradeCard: some View {
        Button {
            appState.presentPaywall(source: "home_upgrade_card")
            AnalyticsService.shared.track(.upgradeTapped(source: "home_upgrade_card"))
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Unlock your full plan")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    Text("Full 7-day plan + progress insights + smart reminders")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Text("See Pro")
                    .font(Theme.Typography.button)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Color.appTeal)
                    .foregroundStyle(.textOnDark)
                    .clipShape(Capsule())
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            AnalyticsService.shared.track(.upgradeCardViewed(source: "home"))
        }
    }

    // MARK: - Helper Methods

    private func handleAutoStartIfNeeded() {
        if appState.shouldStartNextSession {
            appState.shouldStartNextSession = false
            startNextSession()
        }
    }

    private func startNextSession() {
        guard let session = nextIncompleteSession,
              !isNextSessionLocked else {
            if isNextSessionLocked {
                appState.presentPaywall(source: "auto_start_locked")
            }
            return
        }
        startSession(session)
    }

    private func startSession(_ session: MicroSession) {
        // Convert MicroSession to PlannedSession for coordinator
        let plannedSession = PlannedSession(
            type: session.sessionType,
            title: session.title,
            exerciseIds: session.exerciseIds,
            durationSeconds: session.durationSeconds
        )
        AnalyticsService.shared.track(.sessionStartedFromSource(
            sessionId: session.id.uuidString,
            source: "home"
        ))
        sessionCoordinator.startSession(plannedSession)
    }

    private func generatePlanIfNeeded() {
        guard let profile = profile, currentWeeklyPlan == nil else { return }
        let _ = PlanGeneratorService.shared.getOrCreateWeeklyPlan(context: modelContext, profile: profile)
    }
}

// MARK: - Next Session Card

struct NextSessionCard: View {
    let session: MicroSession
    let isLocked: Bool
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Text("Next Session")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textTertiary)

                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.textTertiary)
                        }
                    }

                    Text(session.title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)
                }

                Spacer()

                Text(session.displayDuration)
                    .font(Theme.Typography.body)
                    .foregroundStyle(.textSecondary)
            }

            Text(sessionBenefitText)
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
                .lineLimit(2)

            Button(action: onStart) {
                HStack {
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                        Text("Unlock Session")
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                        Text("Start Session")
                    }
                }
                .font(Theme.Typography.button)
                .foregroundStyle(.textOnDark)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Height.primaryButton)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.pill)
                        .fill(isLocked ? Color.textSecondary : Color.appTeal)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    private var sessionBenefitText: String {
        switch session.sessionType {
        case .morning:
            return "Loosen stiffness + energize for the day ahead"
        case .midday:
            return "Reset tension + refresh your focus"
        case .afternoon:
            return "Release built-up strain + wind down"
        }
    }
}

// MARK: - Pro Badge

struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(AppTheme.textOnAccent)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(AppTheme.accent)
            )
    }
}

// MARK: - View Model

@MainActor
class HomeTabViewModel: ObservableObject {
    @Published var todayScore: Int = 60
    @Published var scoreCategory: ScoreDisplayCategory = .starting
    @Published var todayFocus: String?
    @Published var nextSession: MicroSession?
    @Published var isNextSessionLocked: Bool = false
    @Published var todayInsight: InsightCard?
    @Published var nextReminderTime: String?

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    func loadData(profile: UserProfile?, progressStore: ProgressStore) {
        // Load today's score
        if let todayEntry = progressStore.todaysEntry() {
            todayScore = todayEntry.score
            scoreCategory = todayEntry.scoreCategory
        } else {
            // Default score for new day
            let streak = profile?.currentStreak ?? 0
            todayScore = ScoreEngine.shared.calculateScore(
                sessionsCompleted: 0,
                minutesCompleted: 0,
                streakDays: streak
            )
            scoreCategory = ScoreDisplayCategory.from(score: todayScore)
        }

        // Load insight from analysis report
        if let report = AnalysisReportStore.shared.load() {
            todayInsight = report.insights.first
            todayFocus = report.focusAreas.prefix(2).joined(separator: " & ")
        }

        // Load reminder info
        loadReminderInfo(profile: profile)
    }

    func setNextSession(_ session: MicroSession?, isLocked: Bool) {
        self.nextSession = session
        self.isNextSessionLocked = isLocked
    }

    private func loadReminderInfo(profile: UserProfile?) {
        guard let profile = profile else { return }

        let frequency = ReminderFrequency(rawValue: profile.reminderFrequency)
        guard frequency != .off else {
            nextReminderTime = nil
            return
        }

        // Calculate next reminder (simplified)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)

        // Simple logic: show next reminder based on frequency
        var nextHour: Int
        switch frequency {
        case .hourly:
            nextHour = hour + 1
        case .every2Hours:
            nextHour = ((hour / 2) + 1) * 2
        case .threeDaily:
            if hour < 10 {
                nextHour = 10
            } else if hour < 14 {
                nextHour = 14
            } else if hour < 17 {
                nextHour = 17
            } else {
                nextHour = 10 // Tomorrow
            }
        default:
            nextReminderTime = nil
            return
        }

        if nextHour > 18 {
            nextReminderTime = nil // No more today
        } else {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = nextHour
            components.minute = 0
            if let date = calendar.date(from: components) {
                nextReminderTime = formatter.string(from: date)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeTabView(sessionCoordinator: HomeSessionCoordinator())
    }
    .environmentObject(AppState())
    .environmentObject(SubscriptionManager.shared)
    .environmentObject(ProgressStore.shared)
}
