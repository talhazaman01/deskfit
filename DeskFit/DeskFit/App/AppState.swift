import SwiftUI
import Combine

enum AppDestination: Hashable {
    case session(PlannedSession)
    case reminders
    case settings
}

enum DeepLink {
    case startNextSession
    case home
}

@MainActor
class AppState: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var showPaywall = false
    @Published var paywallSource = ""
    @Published var pendingDeepLink: DeepLink?
    @Published var shouldStartNextSession = false

    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore = false

    func presentPaywall(source: String) {
        paywallSource = source
        showPaywall = true
    }

    func navigateTo(_ destination: AppDestination) {
        navigationPath.append(destination)
    }

    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
