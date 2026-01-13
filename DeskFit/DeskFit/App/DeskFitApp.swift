import SwiftUI
import SwiftData
import UserNotifications
import Combine

@main
struct DeskFitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var entitlementStore = EntitlementStore.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            SessionRecord.self,
            DailyPlan.self,
            WeeklyPlan.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(subscriptionManager)
                .environmentObject(entitlementStore)
                .onAppear {
                    AnalyticsService.shared.track(.appOpened(isFirstLaunch: !appState.hasLaunchedBefore))
                    appState.hasLaunchedBefore = true

                    // Refresh entitlements on app launch
                    Task {
                        await entitlementStore.refreshIfStale()
                    }
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "deskfit" else { return }

        switch url.host {
        case "start-session":
            appState.pendingDeepLink = .startNextSession
        case "home":
            appState.pendingDeepLink = .home
        default:
            break
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationService.shared.setupNotificationCategories()

        // Start AirPods detection service to monitor headphone routes
        Task { @MainActor in
            AirPodsDetectionService.shared.startListening()
        }

        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier

        Task { @MainActor in
            switch actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                NotificationCenter.default.post(
                    name: .notificationTapped,
                    object: nil,
                    userInfo: ["action": "open"]
                )
                AnalyticsService.shared.track(.reminderTapped(action: "open"))

            case NotificationAction.snooze15.rawValue:
                await NotificationService.shared.scheduleSnooze(minutes: 15)
                AnalyticsService.shared.track(.reminderTapped(action: "snooze_15"))

            case NotificationAction.snooze60.rawValue:
                await NotificationService.shared.scheduleSnooze(minutes: 60)
                AnalyticsService.shared.track(.reminderTapped(action: "snooze_60"))

            case NotificationAction.startNow.rawValue:
                NotificationCenter.default.post(
                    name: .notificationTapped,
                    object: nil,
                    userInfo: ["action": "start_session"]
                )
                AnalyticsService.shared.track(.reminderTapped(action: "start_now"))

            default:
                break
            }
        }

        completionHandler()
    }
}

extension Notification.Name {
    static let notificationTapped = Notification.Name("notificationTapped")
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        Group {
            if let profile = profiles.first {
                if !profile.onboardingCompleted {
                    OnboardingFlowView()
                } else {
                    MainTabView()
                }
            } else {
                OnboardingFlowView()
                    .onAppear {
                        createInitialProfile()
                    }
            }
        }
        .sheet(isPresented: $appState.showPaywall) {
            PaywallView(source: appState.paywallSource)
        }
        .onReceive(NotificationCenter.default.publisher(for: .notificationTapped)) { notification in
            handleNotificationAction(notification)
        }
        // Light/Dark mode now adapts automatically via AppTheme tokens
    }

    private func createInitialProfile() {
        let profile = UserProfile()
        modelContext.insert(profile)
        try? modelContext.save()
    }

    private func handleNotificationAction(_ notification: Notification) {
        guard let action = notification.userInfo?["action"] as? String else { return }

        switch action {
        case "start_session":
            appState.shouldStartNextSession = true
        default:
            break
        }
    }
}

// MARK: - Tab Selection

enum MainTab: String, CaseIterable {
    case home
    case training
    case progress

    var title: String {
        switch self {
        case .home: return "Home"
        case .training: return "Training"
        case .progress: return "Progress"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .training: return "figure.run"
        case .progress: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var progressStore = ProgressStore.shared
    @StateObject private var homeCoordinator = HomeSessionCoordinator()
    @StateObject private var trainingCoordinator = TrainingSessionCoordinator()
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Home Tab
            NavigationStack(path: $appState.navigationPath) {
                HomeTabView(sessionCoordinator: homeCoordinator)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tag(MainTab.home)
            .tabItem {
                Label(MainTab.home.title, systemImage: MainTab.home.icon)
            }
            .fullScreenCover(item: $homeCoordinator.activeSession) { session in
                SessionPlayerView(
                    plannedSession: session,
                    sourceTab: homeCoordinator.sourceTab,
                    onDismiss: { homeCoordinator.endSession() }
                )
                .environmentObject(progressStore)
                .environmentObject(appState)
            }

            // MARK: - Training Tab
            NavigationStack {
                TrainingTabView(sessionCoordinator: trainingCoordinator)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tag(MainTab.training)
            .tabItem {
                Label(MainTab.training.title, systemImage: MainTab.training.icon)
            }
            .fullScreenCover(item: $trainingCoordinator.activeSession) { session in
                SessionPlayerView(
                    plannedSession: session,
                    sourceTab: trainingCoordinator.sourceTab,
                    onDismiss: { trainingCoordinator.endSession() }
                )
                .environmentObject(progressStore)
                .environmentObject(appState)
            }

            // MARK: - Progress Tab
            NavigationStack {
                ProgressTabView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tag(MainTab.progress)
            .tabItem {
                Label(MainTab.progress.title, systemImage: MainTab.progress.icon)
            }
        }
        .tint(ThemeColor.accent)
        .environmentObject(progressStore)
        .onAppear {
            configureTabBarAppearance()
            handlePendingDeepLink()
        }
        .onChange(of: selectedTab) { _, newTab in
            AnalyticsService.shared.track(.tabOpened(name: newTab.rawValue))
        }
        .onChange(of: appState.pendingDeepLink) { _, _ in
            handlePendingDeepLink()
        }
    }

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .session:
            // Sessions are now handled via fullScreenCover per tab
            // This case is kept for backwards compatibility but won't be used
            EmptyView()
        case .reminders:
            RemindersView()
        case .settings:
            SettingsView()
        }
    }

    private func handlePendingDeepLink() {
        guard let deepLink = appState.pendingDeepLink else { return }
        appState.pendingDeepLink = nil

        switch deepLink {
        case .startNextSession:
            selectedTab = .home
            appState.shouldStartNextSession = true
        case .home:
            selectedTab = .home
            appState.popToRoot()
        }
    }

    private func configureTabBarAppearance() {
        // Tab Bar Appearance - uses AppTheme tokens for premium teal theme
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = AppTheme.tabBarBgUI

        // Configure item colors using adaptive theme tokens
        // Selected uses accent teal for visibility, unselected uses secondary text
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppTheme.tabBarUnselectedUI
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppTheme.tabBarSelectedUI
        ]

        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = AppTheme.tabBarUnselectedUI
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = AppTheme.tabBarSelectedUI
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Navigation Bar Appearance - uses AppTheme tokens for premium teal theme
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = AppTheme.appBackgroundUI
        navBarAppearance.titleTextAttributes = [.foregroundColor: AppTheme.textPrimaryUI]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: AppTheme.textPrimaryUI]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = AppTheme.accentUI
    }
}
