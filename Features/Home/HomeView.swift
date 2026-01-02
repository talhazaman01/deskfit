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
            VStack(spacing: 24) {
                if let profile = profile {
                    StatsHeaderView(profile: profile)
                }

                if !subscriptionManager.isProUser {
                    ProBanner {
                        appState.presentPaywall(source: "home_banner")
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Resets")
                        .font(.title2)
                        .fontWeight(.bold)

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
                            .onAppear {
                                generateTodaysPlan()
                            }
                    }
                }

                if let plan = todaysPlan, let nextSession = plan.sessions.first(where: { !$0.isCompleted }) {
                    let sessionIndex = plan.sessions.firstIndex(where: { $0.id == nextSession.id }) ?? 0
                    let isLocked = !subscriptionManager.isProUser && sessionIndex > 0

                    if !isLocked {
                        PrimaryButton(title: "Start Next Break") {
                            appState.navigateTo(.session(nextSession))
                        }
                    }
                } else if todaysPlan?.sessions.allSatisfy({ $0.isCompleted }) == true {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)
                        Text("All done for today!")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("DeskFit")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.navigateTo(.settings)
                } label: {
                    Image(systemName: "gearshape")
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

struct ProBanner: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock all resets")
                        .font(.headline)
                    Text("Get personalized daily plans")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Go Pro")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.brandPrimary)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondaryBackground)
            )
        }
        .buttonStyle(.plain)
    }
}
