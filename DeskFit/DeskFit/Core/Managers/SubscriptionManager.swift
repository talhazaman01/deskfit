import Foundation
import Combine
import StoreKit

/// SubscriptionManager is the single source of truth for subscription state.
/// It derives entitlement status directly from StoreKit 2 - no caching in UserProfile.
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    // Product identifiers - configure these in App Store Connect
    // Pricing: $4.99/mo, $29.99/yr (annual = 50% savings)
    // Trial: 7 days on annual only
    static let monthlyProductId = "com.deskfit.pro.monthly"
    static let annualProductId = "com.deskfit.pro.annual"
    static let proEntitlementProductIds: Set<String> = [monthlyProductId, annualProductId]

    // Published state
    @Published private(set) var products: [Product] = []
    @Published private(set) var entitledProductIds: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var currentSubscriptionStatus: SubscriptionStatus = .unknown
    @Published var errorMessage: String?

    // Derived entitlement - this is THE source of truth
    var isProUser: Bool {
        !entitledProductIds.isEmpty
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyProductId }
    }

    var annualProduct: Product? {
        products.first { $0.id == Self.annualProductId }
    }

    private var updateListenerTask: Task<Void, Error>?
    private var previousStatus: SubscriptionStatus = .unknown

    init() {
        updateListenerTask = listenForTransactionUpdates()

        Task {
            await loadProducts()
            await updateEntitlementStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let productIds = [Self.monthlyProductId, Self.annualProductId]
            let storeProducts = try await Product.products(for: productIds)

            // Sort by price (monthly first, then annual)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load subscription options. Please try again."
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Entitlement Check (Source of Truth)

    func updateEntitlementStatus() async {
        var entitled: Set<String> = []
        var newStatus: SubscriptionStatus = .free

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if Self.proEntitlementProductIds.contains(transaction.productID) {
                entitled.insert(transaction.productID)

                if transaction.offer?.type == .introductory {
                    newStatus = .trial
                } else {
                    newStatus = .subscribed
                }
            }
        }

        entitledProductIds = entitled

        if entitled.isEmpty {
            if previousStatus == .subscribed || previousStatus == .trial {
                newStatus = .expired
            } else {
                newStatus = .free
            }
        }

        if previousStatus != .unknown && previousStatus != newStatus {
            AnalyticsService.shared.track(.subscriptionStatusChanged(
                previousStatus: previousStatus.rawValue,
                newStatus: newStatus.rawValue
            ))
        }

        previousStatus = currentSubscriptionStatus
        currentSubscriptionStatus = newStatus
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            await transaction.finish()
            await updateEntitlementStatus()

            let isTrial = transaction.offer?.type == .introductory
            let planName = product.id.contains("annual") ? "annual" : "monthly"

            AnalyticsService.shared.track(.subscribeSuccess(
                plan: planName,
                price: product.price,
                currency: product.priceFormatStyle.currencyCode,
                isTrial: isTrial
            ))

            if isTrial {
                AnalyticsService.shared.track(.trialStarted(plan: planName, trialDays: 7))
            }

            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updateEntitlementStatus()

            if isProUser {
                let plan = entitledProductIds.first { $0.contains("annual") } != nil ? "annual" : "monthly"
                AnalyticsService.shared.track(.subscribeRestored(plan: plan))
            }
        } catch {
            errorMessage = "Failed to restore purchases. Please try again."
            print("Restore failed: \(error)")
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactionUpdates() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }

                await transaction.finish()
                await self?.updateEntitlementStatus()
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw StoreError.verificationFailed(error)
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: LocalizedError {
    case verificationFailed(Error)
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .verificationFailed(let error):
            return "Verification failed: \(error.localizedDescription)"
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        }
    }
}
