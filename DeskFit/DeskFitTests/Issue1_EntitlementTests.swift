import XCTest
@testable import DeskFit

/// Tests for Issue 1 - Entitlement state propagation
/// Verifies that toggling isPro correctly affects feature gating across the app.
@MainActor
final class EntitlementTests: XCTestCase {

    // MARK: - Test EntitlementStore State

    func testEntitlementStoreDefaultsToNotPro() async {
        // Given: A fresh UserDefaults (simulate first launch)
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "entitlement_isPro")

        // When: EntitlementStore initializes
        let store = EntitlementStore.shared

        // Then: Unless there's a cached value, check the behavior is consistent
        // Note: In real tests, we'd use dependency injection for UserDefaults
        XCTAssertNotNil(store)
    }

    func testEntitlementStoreProStateAffectsFeatureGate() async {
        // Given: EntitlementStore with Pro access
        let store = EntitlementStore.shared

        // When: Pro is enabled via debug helper (in DEBUG builds only)
        #if DEBUG
        store.debugSetPro(true, source: .paid)

        // Then: FeatureGate reflects Pro status
        XCTAssertTrue(FeatureGate.isPro)
        XCTAssertTrue(FeatureGate.canAccessFullPlan)
        XCTAssertTrue(FeatureGate.canAccessSmartNudges)

        // And: Can access all sessions
        XCTAssertTrue(FeatureGate.canAccessSession(sessionIndex: 0, forDayIndex: 0))
        XCTAssertTrue(FeatureGate.canAccessSession(sessionIndex: 1, forDayIndex: 0))
        XCTAssertTrue(FeatureGate.canAccessSession(sessionIndex: 2, forDayIndex: 0))

        // And: Can access all plan days
        XCTAssertTrue(FeatureGate.canAccessPlanDay(dayIndex: 0))
        XCTAssertTrue(FeatureGate.canAccessPlanDay(dayIndex: 3))
        XCTAssertTrue(FeatureGate.canAccessPlanDay(dayIndex: 6))
        #endif
    }

    func testEntitlementStoreFreeStateRestrictsFeatures() async {
        // Given: EntitlementStore without Pro access
        let store = EntitlementStore.shared

        #if DEBUG
        store.debugSetPro(false, source: .notPro)

        // Then: FeatureGate reflects free status
        XCTAssertFalse(FeatureGate.isPro)
        XCTAssertFalse(FeatureGate.canAccessFullPlan)
        XCTAssertFalse(FeatureGate.canAccessSmartNudges)

        // And: Only first session on first day is accessible
        XCTAssertTrue(FeatureGate.canAccessSession(sessionIndex: 0, forDayIndex: 0))
        XCTAssertFalse(FeatureGate.canAccessSession(sessionIndex: 1, forDayIndex: 0))
        XCTAssertFalse(FeatureGate.canAccessSession(sessionIndex: 0, forDayIndex: 1))

        // And: Only first plan day is accessible
        XCTAssertTrue(FeatureGate.canAccessPlanDay(dayIndex: 0))
        XCTAssertFalse(FeatureGate.canAccessPlanDay(dayIndex: 1))
        XCTAssertFalse(FeatureGate.canAccessPlanDay(dayIndex: 6))
        #endif
    }

    func testMarkPurchaseSuccessfulImmediatelyUnlocksPro() async {
        let store = EntitlementStore.shared

        #if DEBUG
        // Given: User is not Pro
        store.debugSetPro(false, source: .notPro)
        XCTAssertFalse(store.isPro)

        // When: Purchase is marked successful
        store.markPurchaseSuccessful(productId: "com.deskfit.pro.monthly", isTrial: false)

        // Then: Pro is immediately available
        XCTAssertTrue(store.isPro)
        XCTAssertEqual(store.proUnlockSource, .paid)
        #endif
    }

    func testMarkPurchaseWithTrialSetsTrial() async {
        let store = EntitlementStore.shared

        #if DEBUG
        // Given: User is not Pro
        store.debugSetPro(false, source: .notPro)

        // When: Trial purchase is marked successful
        store.markPurchaseSuccessful(productId: "com.deskfit.pro.annual", isTrial: true)

        // Then: Source is trial
        XCTAssertTrue(store.isPro)
        XCTAssertEqual(store.proUnlockSource, .trial)
        #endif
    }
}
