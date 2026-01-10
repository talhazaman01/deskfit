import Foundation
import Combine
import StoreKit

// MARK: - Pro Unlock Source

/// Tracks how the user got Pro access
enum ProUnlockSource: String, Codable, Sendable {
    case notPro
    case trial
    case paid
    case restored
}

// MARK: - Entitlement Store

/// Single source of truth for all entitlement state in the app.
/// All UI should reference this store for Pro gating decisions.
///
/// Key behaviors:
/// - On app launch: shows cached `isPro` instantly (optimistic), then refreshes async
/// - On purchase: immediately sets `isPro = true` and persists, then refreshes in background
/// - All views observe via EnvironmentObject
@MainActor
final class EntitlementStore: ObservableObject {

    // MARK: - Singleton

    static let shared = EntitlementStore()

    // MARK: - Published State

    /// Whether user has Pro access - THE source of truth for all UI gating
    @Published private(set) var isPro: Bool {
        didSet {
            // Persist immediately when changed
            persistState()

            if isPro != oldValue {
                let event = isPro ? "pro_unlocked" : "pro_revoked"
                print("[EntitlementStore] \(event) - isPro=\(isPro), source=\(proUnlockSource.rawValue)")
            }
        }
    }

    /// Set of active product IDs user is entitled to
    @Published private(set) var activeProductIds: Set<String> = []

    /// How user got Pro access (for analytics)
    @Published private(set) var proUnlockSource: ProUnlockSource = .notPro

    /// When entitlements were last verified with StoreKit
    @Published private(set) var lastVerifiedAt: Date?

    /// Whether a refresh is in progress
    @Published private(set) var isRefreshing: Bool = false

    // MARK: - Persistence Keys

    private enum Keys {
        static let isPro = "entitlement_isPro"
        static let proUnlockSource = "entitlement_proUnlockSource"
        static let lastVerifiedAt = "entitlement_lastVerifiedAt"
        static let activeProductIds = "entitlement_activeProductIds"
    }

    // MARK: - Configuration

    private static let proProductIds: Set<String> = [
        "com.deskfit.pro.monthly",
        "com.deskfit.pro.annual"
    ]

    /// How often to auto-refresh (30 minutes)
    private static let autoRefreshInterval: TimeInterval = 30 * 60

    // MARK: - Private State

    private var refreshTask: Task<Void, Never>?
    private var transactionListenerTask: Task<Void, Error>?

    // MARK: - Initialization

    private init() {
        // Load persisted state immediately for instant UI
        self.isPro = UserDefaults.standard.bool(forKey: Keys.isPro)

        if let sourceRaw = UserDefaults.standard.string(forKey: Keys.proUnlockSource),
           let source = ProUnlockSource(rawValue: sourceRaw) {
            self.proUnlockSource = source
        }

        if let lastVerified = UserDefaults.standard.object(forKey: Keys.lastVerifiedAt) as? Date {
            self.lastVerifiedAt = lastVerified
        }

        if let productIdsData = UserDefaults.standard.data(forKey: Keys.activeProductIds),
           let productIds = try? JSONDecoder().decode(Set<String>.self, from: productIdsData) {
            self.activeProductIds = productIds
        }

        print("[EntitlementStore] init - cached isPro=\(isPro), source=\(proUnlockSource.rawValue)")

        // Start transaction listener
        transactionListenerTask = listenForTransactionUpdates()

        // Refresh in background (don't block UI)
        Task {
            await refreshEntitlements()
        }
    }

    deinit {
        refreshTask?.cancel()
        transactionListenerTask?.cancel()
    }

    // MARK: - Public API

    /// Refresh entitlements from StoreKit. Call after purchase, restore, or app foreground.
    func refreshEntitlements() async {
        guard !isRefreshing else {
            print("[EntitlementStore] refreshEntitlements() skipped - already refreshing")
            return
        }

        isRefreshing = true
        defer { isRefreshing = false }

        print("[EntitlementStore] refreshEntitlements() starting...")

        var entitledIds: Set<String> = []
        var detectedSource: ProUnlockSource = .notPro

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if Self.proProductIds.contains(transaction.productID) {
                entitledIds.insert(transaction.productID)

                // Determine source
                if transaction.offer?.type == .introductory {
                    detectedSource = .trial
                } else {
                    // Check if this is from a restore by looking at original purchase date
                    // If original purchase was > 1 minute ago and we just got it, likely a restore
                    let timeSinceOriginal = Date().timeIntervalSince(transaction.originalPurchaseDate)
                    if timeSinceOriginal > 60 && detectedSource == .notPro {
                        detectedSource = .restored
                    } else {
                        detectedSource = .paid
                    }
                }
            }
        }

        // Update state
        let wasProBefore = isPro
        activeProductIds = entitledIds
        isPro = !entitledIds.isEmpty

        if isPro {
            // Keep the more specific source if already set
            if proUnlockSource == .notPro {
                proUnlockSource = detectedSource
            }
        } else {
            proUnlockSource = .notPro
        }

        lastVerifiedAt = Date()

        // Track analytics
        if isPro && !wasProBefore {
            AnalyticsService.shared.track(.proUnlocked(source: proUnlockSource.rawValue))
        } else if !isPro && wasProBefore {
            AnalyticsService.shared.track(.proRevoked)
        }

        AnalyticsService.shared.track(.entitlementsRefreshed(
            isPro: isPro,
            productCount: entitledIds.count
        ))


        print("[EntitlementStore] refreshEntitlements() done - isPro=\(isPro), products=\(entitledIds)")
    }

    /// Called immediately after a successful purchase - sets Pro instantly before StoreKit verification
    func markPurchaseSuccessful(productId: String, isTrial: Bool) {
        print("[EntitlementStore] markPurchaseSuccessful - product=\(productId), isTrial=\(isTrial)")

        // Immediately unlock Pro
        activeProductIds.insert(productId)
        isPro = true
        proUnlockSource = isTrial ? .trial : .paid
        lastVerifiedAt = Date()

        // Track analytics
        AnalyticsService.shared.track(.proUnlocked(source: proUnlockSource.rawValue))

        // Schedule background refresh to ensure consistency
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
            await refreshEntitlements()
        }
    }

    /// Called after restore purchases completes
    func markRestoreSuccessful() {
        print("[EntitlementStore] markRestoreSuccessful")

        Task {
            await refreshEntitlements()
            if isPro {
                proUnlockSource = .restored
                AnalyticsService.shared.track(.proUnlocked(source: "restored"))
            }
        }
    }

    /// Check if auto-refresh is needed (called on app foreground)
    func refreshIfStale() async {
        guard let lastVerified = lastVerifiedAt else {
            await refreshEntitlements()
            return
        }

        let timeSinceLastRefresh = Date().timeIntervalSince(lastVerified)
        if timeSinceLastRefresh > Self.autoRefreshInterval {
            print("[EntitlementStore] refreshIfStale - stale by \(Int(timeSinceLastRefresh))s, refreshing...")
            await refreshEntitlements()
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactionUpdates() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }

                await transaction.finish()
                await self?.refreshEntitlements()
            }
        }
    }

    // MARK: - Persistence

    private func persistState() {
        UserDefaults.standard.set(isPro, forKey: Keys.isPro)
        UserDefaults.standard.set(proUnlockSource.rawValue, forKey: Keys.proUnlockSource)

        if let lastVerified = lastVerifiedAt {
            UserDefaults.standard.set(lastVerified, forKey: Keys.lastVerifiedAt)
        }

        if let data = try? JSONEncoder().encode(activeProductIds) {
            UserDefaults.standard.set(data, forKey: Keys.activeProductIds)
        }
    }

    // MARK: - Debug Helpers

    #if DEBUG
    /// For testing - simulate Pro state
    func debugSetPro(_ isPro: Bool, source: ProUnlockSource = .paid) {
        print("[EntitlementStore] DEBUG - setting isPro=\(isPro)")
        self.isPro = isPro
        self.proUnlockSource = source
        self.lastVerifiedAt = Date()
    }
    #endif
}

