import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var entitlementStore: EntitlementStore
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyPlan.date, order: .reverse) private var plans: [DailyPlan]

    @StateObject private var viewModel = HomeViewModel()

    private var profile: UserProfile? {
        profiles.first
    }

    private var todaysPlan: DailyPlan? {
        plans.first { Calendar.current.isDateInToday($0.date) }
    }

    private var nextIncompleteSession: PlannedSession? {
        todaysPlan?.sessions.first(where: { !$0.isCompleted })
    }

    private var nextSessionIndex: Int {
        guard let plan = todaysPlan, let session = nextIncompleteSession else { return 0 }
        return plan.sessions.firstIndex(where: { $0.id == session.id }) ?? 0
    }

    private var isNextSessionLocked: Bool {
        !entitlementStore.isPro && nextSessionIndex > 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Stats header
                if let profile = profile {
                    StatsHeaderView(
                        profile: profile,
                        todayMinutes: viewModel.calculateTodayMinutes(plan: todaysPlan)
                    )
                }

                // Primary CTA Section
                primaryCTASection

                // Today's Insight - personalized daily tip
                TodayInsightSection()

                // Pro banner for free users (dynamic)
                if !entitlementStore.isPro, let profile = profile {
                    DynamicProBannerView(
                        upsellText: viewModel.proUpsellText(for: profile)
                    ) {
                        appState.presentPaywall(source: "home_banner")
                    }
                }

                // Today's sessions
                sessionsSection
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
            if let profile = profile {
                StreakService.shared.checkAndResetStreak(for: profile, context: modelContext)
                Task {
                    await viewModel.updateReminderInfo(profile: profile)
                }
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

    // MARK: - Primary CTA Section

    @ViewBuilder
    private var primaryCTASection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if todaysPlan?.sessions.allSatisfy({ $0.isCompleted }) == true {
                // All done
                CompletionBadgeView()
            } else if let nextSession = nextIncompleteSession {
                if isNextSessionLocked {
                    // Locked - show unlock CTA
                    LockedCTAView(sessionTitle: nextSession.title) {
                        appState.presentPaywall(source: "locked_cta")
                    }
                } else {
                    // Available - show contextual start button
                    PrimaryButton(title: viewModel.contextualCTATitle(for: nextSession)) {
                        appState.navigateTo(.session(nextSession))
                    }
                }

                // Reminder info line
                ReminderInfoLine(
                    nextReminderTime: viewModel.nextReminderFormatted,
                    remindersEnabled: viewModel.remindersEnabled,
                    onEnableReminders: {
                        appState.navigateTo(.reminders)
                    }
                )
            } else if todaysPlan == nil {
                // Loading plan
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .onAppear {
                        generateTodaysPlan()
                    }
            }
        }
    }

    // MARK: - Sessions Section

    @ViewBuilder
    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("Today's Resets")
                .font(Theme.Typography.title)
                .foregroundStyle(.textPrimary)

            if let plan = todaysPlan {
                ForEach(Array(plan.sessions.enumerated()), id: \.element.id) { index, session in
                    SessionCardView(
                        session: session,
                        isLocked: !entitlementStore.isPro && index > 0,
                        lockReason: index > 0 ? "Unlock with Pro to access all daily resets" : nil,
                        onTap: {
                            if entitlementStore.isPro || index == 0 {
                                appState.navigateTo(.session(session))
                            } else {
                                appState.presentPaywall(source: "locked_session")
                            }
                        }
                    )
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .onAppear {
                        generateTodaysPlan()
                    }
            }
        }
    }

    // MARK: - Helper Methods

    private func generateTodaysPlan() {
        guard let profile = profile else { return }
        let _ = PlanGeneratorService.shared.getTodaysPlan(context: modelContext, profile: profile)
    }

    private func handleAutoStartIfNeeded() {
        if appState.shouldStartNextSession {
            appState.shouldStartNextSession = false
            startNextSession()
        }
    }

    private func startNextSession() {
        guard let plan = todaysPlan,
              let nextSession = plan.sessions.first(where: { !$0.isCompleted }) else { return }

        let sessionIndex = plan.sessions.firstIndex(where: { $0.id == nextSession.id }) ?? 0
        let isLocked = !entitlementStore.isPro && sessionIndex > 0

        if !isLocked {
            appState.navigateTo(.session(nextSession))
        } else {
            appState.presentPaywall(source: "notification_start")
        }
    }
}

// MARK: - Subviews

struct DynamicProBannerView: View {
    let upsellText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(upsellText)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    Text("Get unlimited daily breaks")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()

                Text("Go Pro")
                    .font(Theme.Typography.button)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Color.appTeal)
                    .foregroundStyle(.textOnDark)
                    .clipShape(Capsule())
            }
            .deskFitCardStyle()
        }
        .buttonStyle(.plain)
    }
}

struct ReminderInfoLine: View {
    let nextReminderTime: String?
    let remindersEnabled: Bool
    let onEnableReminders: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "bell.fill")
                .font(.caption)
                .foregroundStyle(.textTertiary)

            if remindersEnabled, let time = nextReminderTime {
                Text("Next reminder at \(time)")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            } else {
                Text("Reminders off")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)

                Button("Enable") {
                    onEnableReminders()
                }
                .font(Theme.Typography.caption)
                .foregroundStyle(.appTeal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Theme.Spacing.xs)
    }
}

struct LockedCTAView: View {
    let sessionTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))

                Text("Unlock \(sessionTitle)")
                    .font(Theme.Typography.button)
            }
            .foregroundStyle(.textOnDark)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Height.primaryButton)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.pill)
                    .fill(Color.appTeal)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CompletionBadgeView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.success)

            Text("All done for today!")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textSecondary)

            Text("Great job keeping up with your resets")
                .font(Theme.Typography.caption)
                .foregroundStyle(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
    }
}
