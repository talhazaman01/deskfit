import Foundation
import Combine
import StoreKit

// MARK: - StoreKit Simulator Setup
/*
 To test In-App Purchases on the Simulator, you MUST attach a StoreKit Configuration file:

 1. In Xcode: File > New > File > StoreKit Configuration File
    - Name it: DeskFit.storekit
    - Add it to DeskFit target

 2. Configure the scheme:
    Product > Scheme > Edit Scheme > Run > Options
    > StoreKit Configuration: DeskFit.storekit

 3. The config should contain two auto-renewable subscriptions:
    - com.deskfit.pro.monthly  ($4.99/month, no trial)
    - com.deskfit.pro.annual   ($29.99/year, 7-day free trial)

 Without this setup, Product.products(for:) returns an empty array on Simulator.
*/

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

    // Configuration
    static let productLoadTimeout: TimeInterval = 10.0

    // Published state
    @Published private(set) var products: [Product] = []
    @Published private(set) var entitledProductIds: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var currentSubscriptionStatus: SubscriptionStatus = .unknown

    // Loading states for UI - this is the single source of truth for product load status
    @Published private(set) var productLoadState: ProductLoadState = .idle
    @Published private(set) var lastStoreKitError: StoreKitError?

    enum ProductLoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(reason: FailureReason)
        case timeout

        enum FailureReason: String, Equatable {
            case networkError = "network_error"
            case storeKitError = "storekit_error"
            case noProductsFound = "no_products_found"
            case simulatorMissingConfig = "simulator_missing_config"
            case unknown = "unknown"
        }

        var isTerminal: Bool {
            switch self {
            case .loaded, .failed, .timeout:
                return true
            case .idle, .loading:
                return false
            }
        }
    }

    struct StoreKitError {
        let code: String
        let description: String
        let underlyingError: Error?
    }

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

    var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    /// User-facing error message derived from productLoadState
    var userFacingErrorMessage: String? {
        switch productLoadState {
        case .timeout:
            return "Connection timed out. Please check your internet and try again."
        case .failed(let reason):
            switch reason {
            case .networkError:
                return "Unable to connect. Please check your internet connection."
            case .simulatorMissingConfig:
                return "Store not configured for Simulator. Attach DeskFit.storekit to your Run Scheme."
            case .noProductsFound:
                return "Subscription products unavailable. Please try again later."
            case .storeKitError, .unknown:
                return "Something went wrong. Please try again."
            }
        default:
            return nil
        }
    }

    private var updateListenerTask: Task<Void, Error>?
    private var previousStatus: SubscriptionStatus = .unknown
    private var loadProductsTask: Task<Void, Never>?

    #if DEBUG
    // Guard against multiple instances (debug only)
    // nonisolated(unsafe) because deinit is always nonisolated
    nonisolated(unsafe) private static var instanceCount = 0
    #endif

    init() {
        #if DEBUG
        Self.instanceCount += 1
        logDebug("init() called - instance #\(Self.instanceCount)")

        if Self.instanceCount > 1 {
            logDebug("⚠️ WARNING: Multiple SubscriptionManager instances detected. Use SubscriptionManager.shared instead.")
        }
        #endif

        updateListenerTask = listenForTransactionUpdates()

        // Load products once on init - guarded against re-entry
        Task {
            await loadProducts()
            await updateEntitlementStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
        loadProductsTask?.cancel()
        #if DEBUG
        Self.instanceCount -= 1
        #endif
    }

    // MARK: - Product Loading with Deduplication

    /// Loads products from the App Store or StoreKit configuration.
    /// - Parameter force: If true, reloads even if products are already loaded.
    ///                    Use for "Try Again" buttons after failures.
    func loadProducts(force: Bool = false) async {
        // Dedup guard: don't reload if already loaded (unless forced)
        if !force && productLoadState == .loaded && !products.isEmpty {
            logDebug("loadProducts() skipped - already loaded \(products.count) products")
            return
        }

        // Dedup guard: don't run if already loading
        if productLoadState == .loading {
            logDebug("loadProducts() skipped - already loading")
            return
        }

        // Cancel any existing load task
        loadProductsTask?.cancel()

        isLoading = true
        productLoadState = .loading
        lastStoreKitError = nil

        let productIds = [Self.monthlyProductId, Self.annualProductId]
        let environment = isRunningOnSimulator ? "Simulator" : "Device"

        logDebug("loadProducts() starting - environment: \(environment), requesting IDs: \(productIds)")

        defer { isLoading = false }

        do {
            // Load products with timeout
            let storeProducts = try await withThrowingTaskGroup(of: [Product].self) { group in
                group.addTask {
                    try await Product.products(for: productIds)
                }

                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(Self.productLoadTimeout * 1_000_000_000))
                    throw ProductLoadError.timeout
                }

                // Return first successful result
                if let result = try await group.next() {
                    group.cancelAll()
                    return result
                }

                throw ProductLoadError.unknown
            }

            if storeProducts.isEmpty {
                logStoreKitError(
                    code: "EMPTY_PRODUCTS",
                    description: "No products returned from App Store",
                    context: "Environment: \(environment), Requested IDs: \(productIds)"
                )

                // Detect simulator vs device for appropriate error
                if isRunningOnSimulator {
                    productLoadState = .failed(reason: .simulatorMissingConfig)
                    logDebug("❌ Simulator detected with no products - ensure DeskFit.storekit is attached to Run Scheme")
                } else {
                    productLoadState = .failed(reason: .noProductsFound)
                    logDebug("❌ Device: No products found - check App Store Connect: products cleared for sale, sandbox account signed in, agreements accepted")
                }
                return
            }

            // Sort by price (monthly first, then annual)
            products = storeProducts.sorted { $0.price < $1.price }
            productLoadState = .loaded

            logDebug("✅ Successfully loaded \(products.count) products: \(products.map { $0.id })")

        } catch let error as ProductLoadError where error == .timeout {
            logStoreKitError(
                code: "TIMEOUT",
                description: "Product loading timed out after \(Self.productLoadTimeout)s",
                context: "Environment: \(environment)"
            )
            productLoadState = .timeout

        } catch {
            let nsError = error as NSError
            logStoreKitError(
                code: "STOREKIT_\(nsError.code)",
                description: nsError.localizedDescription,
                context: "Environment: \(environment), Domain: \(nsError.domain)",
                underlyingError: error
            )

            // Determine failure reason based on error and environment
            if isRunningOnSimulator && (nsError.domain == "ASDErrorDomain" || nsError.domain == "SKErrorDomain") {
                productLoadState = .failed(reason: .simulatorMissingConfig)
            } else if nsError.domain == NSURLErrorDomain {
                productLoadState = .failed(reason: .networkError)
            } else {
                productLoadState = .failed(reason: .storeKitError)
            }
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

        do {
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
        } catch {
            logStoreKitError(
                code: "PURCHASE_ERROR",
                description: error.localizedDescription,
                underlyingError: error
            )
            throw error
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
            logStoreKitError(
                code: "RESTORE_ERROR",
                description: error.localizedDescription,
                underlyingError: error
            )
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

    // MARK: - Debug Logging

    private func logStoreKitError(code: String, description: String, context: String? = nil, underlyingError: Error? = nil) {
        lastStoreKitError = StoreKitError(
            code: code,
            description: description,
            underlyingError: underlyingError
        )

        #if DEBUG
        print("--- StoreKit Error ---")
        print("  Code: \(code)")
        print("  Description: \(description)")
        if let context = context {
            print("  Context: \(context)")
        }
        if let underlying = underlyingError {
            print("  Underlying: \(underlying)")
            let nsError = underlying as NSError
            print("  Domain: \(nsError.domain)")
            print("  NSError Code: \(nsError.code)")
            print("  UserInfo: \(nsError.userInfo)")
        }
        print("----------------------")
        #endif
    }

    private func logDebug(_ message: String) {
        #if DEBUG
        print("[SubscriptionManager] \(message)")
        #endif
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

// MARK: - Errors

enum ProductLoadError: Error, Equatable {
    case timeout
    case unknown
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
