import SwiftUI
import SwiftData
import UserNotifications

@main
struct DeskFitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @StateObject private var subscriptionManager = SubscriptionManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            SessionRecord.self,
            DailyPlan.self
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
                .onAppear {
                    AnalyticsService.shared.track(.appOpened(isFirstLaunch: !appState.hasLaunchedBefore))
                    appState.hasLaunchedBefore = true
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

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            HomeView()
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .session(let session):
                        SessionPlayerView(plannedSession: session)
                    case .reminders:
                        RemindersView()
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .onAppear {
            handlePendingDeepLink()
        }
        .onChange(of: appState.pendingDeepLink) { _, _ in
            handlePendingDeepLink()
        }
    }

    private func handlePendingDeepLink() {
        guard let deepLink = appState.pendingDeepLink else { return }
        appState.pendingDeepLink = nil

        switch deepLink {
        case .startNextSession:
            appState.shouldStartNextSession = true
        case .home:
            appState.popToRoot()
        }
    }
}
