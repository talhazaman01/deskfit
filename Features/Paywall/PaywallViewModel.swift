import Foundation

enum SubscriptionPlan: String {
    case monthly
    case annual
}

@MainActor
class PaywallViewModel: ObservableObject {
    @Published var selectedPlan: SubscriptionPlan = .annual
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isPurchasing = false
}
