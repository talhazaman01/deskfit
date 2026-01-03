import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyPlan.date, order: .reverse) private var plans: [DailyPlan]

    private var profile: UserProfile? {
        profiles.first
    }

    private var todaysPlan: DailyPlan? {
        plans.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Stats header
                if let profile = profile {
                    StatsHeaderView(profile: profile)
                }

                // Pro banner for free users
                if !subscriptionManager.isProUser {
                    ProBannerView {
                        appState.presentPaywall(source: "home_banner")
                    }
                }

                // Today's sessions
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    Text("Today's Resets")
                        .font(Theme.Typography.title)
                        .foregroundStyle(.textPrimary)

                    if let plan = todaysPlan {
                        ForEach(Array(plan.sessions.enumerated()), id: \.element.id) { index, session in
                            SessionCardView(
                                session: session,
                                isLocked: !subscriptionManager.isProUser && index > 0,
                                onTap: {
                                    if subscriptionManager.isProUser || index == 0 {
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

                // Quick start button
                quickStartSection
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.bottomArea)
        }
        .background(Color.appBackground)
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

    @ViewBuilder
    private var quickStartSection: some View {
        if let plan = todaysPlan, let nextSession = plan.sessions.first(where: { !$0.isCompleted }) {
            let sessionIndex = plan.sessions.firstIndex(where: { $0.id == nextSession.id }) ?? 0
            let isLocked = !subscriptionManager.isProUser && sessionIndex > 0

            if !isLocked {
                PrimaryButton(title: "Start Next Break") {
                    appState.navigateTo(.session(nextSession))
                }
            }
        } else if todaysPlan?.sessions.allSatisfy({ $0.isCompleted }) == true {
            CompletionBadgeView()
        }
    }

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
        let isLocked = !subscriptionManager.isProUser && sessionIndex > 0

        if !isLocked {
            appState.navigateTo(.session(nextSession))
        } else {
            appState.presentPaywall(source: "notification_start")
        }
    }
}

// MARK: - Subviews

struct ProBannerView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Unlock all resets")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    Text("Get personalized daily plans")
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
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.cardBackground)
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
    }
}
