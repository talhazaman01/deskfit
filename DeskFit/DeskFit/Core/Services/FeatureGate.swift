import Foundation

// MARK: - Feature Gate

/// Centralized feature gating based on subscription status.
/// Determines what features are available to free vs. Pro users.
///
/// Free Tier:
/// - Home: Today's summary + 1 "Quick Reset" session per day
/// - Training: Day 1 only or 3 sessions/week preview
/// - Progress: Last 7 days only
///
/// Pro Tier:
/// - Full 7-day plan + all training sessions
/// - Advanced progress insights (trend analysis, focus area breakdown, monthly history)
/// - Smart nudges + reminder scheduling
enum FeatureGate {
    // MARK: - Constants

    /// Number of days of history free users can access
    static let freeHistoryDays = 7

    /// Number of sessions free users can access per day in training
    static let freeSessionsPerDay = 1

    /// Number of plan days free users can preview
    static let freePlanDaysPreview = 1

    /// Maximum sessions per week for free users
    static let freeMaxWeeklySessions = 3

    // MARK: - Core Access Checks

    /// Check if user has Pro subscription - uses EntitlementStore as single source of truth
    @MainActor
    static var isPro: Bool {
        EntitlementStore.shared.isPro
    }

    /// Check if user can access the full 7-day plan
    @MainActor
    static var canAccessFullPlan: Bool {
        isPro
    }

    /// Check if user can access smart nudges feature
    @MainActor
    static var canAccessSmartNudges: Bool {
        isPro
    }

    /// Check if user can access advanced progress insights
    @MainActor
    static var canAccessAdvancedInsights: Bool {
        isPro
    }

    /// Check if user can save favorites
    @MainActor
    static var canSaveFavorites: Bool {
        isPro
    }

    // MARK: - Parameterized Access Checks

    /// Check if user can access history for a specific number of days
    @MainActor
    static func canAccessHistory(days: Int) -> Bool {
        isPro || days <= freeHistoryDays
    }

    /// Check if user can access a specific day in the plan
    @MainActor
    static func canAccessPlanDay(dayIndex: Int) -> Bool {
        isPro || dayIndex < freePlanDaysPreview
    }

    /// Check if user can access a specific session index within a day
    @MainActor
    static func canAccessSession(sessionIndex: Int, forDayIndex dayIndex: Int) -> Bool {
        if isPro { return true }

        // Free users: only first session of day 1
        return dayIndex == 0 && sessionIndex == 0
    }

    /// Check if user has exceeded weekly session limit (for free tier)
    @MainActor
    static func hasExceededWeeklyLimit(completedSessions: Int) -> Bool {
        !isPro && completedSessions >= freeMaxWeeklySessions
    }

    // MARK: - Feature-Specific Gates

    /// Gate for accessing the library filter feature
    @MainActor
    static var canUseLibraryFilters: Bool {
        isPro
    }

    /// Gate for accessing exercise favorites
    @MainActor
    static var canAccessFavorites: Bool {
        isPro
    }

    /// Gate for monthly progress history
    @MainActor
    static var canAccessMonthlyHistory: Bool {
        isPro
    }

    /// Gate for focus area breakdown analytics
    @MainActor
    static var canAccessFocusAreaBreakdown: Bool {
        isPro
    }

    /// Gate for trend analysis
    @MainActor
    static var canAccessTrendAnalysis: Bool {
        isPro
    }

    // MARK: - UI Messaging

    /// Get the upgrade prompt message for a specific feature
    static func upgradePrompt(for feature: GatedFeature) -> UpgradePrompt {
        feature.upgradePrompt
    }

    /// Get lock reason for a session
    @MainActor
    static func sessionLockReason(sessionIndex: Int, dayIndex: Int) -> String? {
        guard !canAccessSession(sessionIndex: sessionIndex, forDayIndex: dayIndex) else {
            return nil
        }

        if dayIndex > 0 {
            return "Unlock with Pro to access Day \(dayIndex + 1)"
        } else {
            return "Unlock with Pro to access all daily resets"
        }
    }
}

// MARK: - Gated Features

/// Enumeration of features that may be gated
enum GatedFeature: String, CaseIterable {
    case fullPlan
    case smartNudges
    case advancedInsights
    case favorites
    case monthlyHistory
    case focusAreaBreakdown
    case trendAnalysis
    case libraryFilters
    case unlimitedSessions

    var displayName: String {
        switch self {
        case .fullPlan: return "Full 7-Day Plan"
        case .smartNudges: return "Smart Nudges"
        case .advancedInsights: return "Advanced Insights"
        case .favorites: return "Save Favorites"
        case .monthlyHistory: return "Monthly History"
        case .focusAreaBreakdown: return "Focus Area Breakdown"
        case .trendAnalysis: return "Trend Analysis"
        case .libraryFilters: return "Library Filters"
        case .unlimitedSessions: return "Unlimited Sessions"
        }
    }

    var upgradePrompt: UpgradePrompt {
        switch self {
        case .fullPlan:
            return UpgradePrompt(
                title: "Unlock your full plan",
                description: "Get all 7 days of personalized sessions designed for your goals.",
                benefit: "Full 7-day plan + progress tracking"
            )
        case .smartNudges:
            return UpgradePrompt(
                title: "Smart reminders",
                description: "Get reminded exactly when you need a reset based on your stiffness patterns.",
                benefit: "Personalized timing for better results"
            )
        case .advancedInsights:
            return UpgradePrompt(
                title: "See your progress",
                description: "Unlock detailed analytics to understand your posture habits.",
                benefit: "Trend analysis + focus area breakdown"
            )
        case .favorites:
            return UpgradePrompt(
                title: "Save your favorites",
                description: "Build a library of your go-to exercises for quick access.",
                benefit: "Quick access to exercises you love"
            )
        case .monthlyHistory:
            return UpgradePrompt(
                title: "Track long-term progress",
                description: "See your full history and how far you've come.",
                benefit: "30+ days of progress data"
            )
        case .focusAreaBreakdown:
            return UpgradePrompt(
                title: "Focus area insights",
                description: "See which areas you're targeting most and where to improve.",
                benefit: "Balanced routine recommendations"
            )
        case .trendAnalysis:
            return UpgradePrompt(
                title: "Understand your trends",
                description: "See how your consistency is trending over time.",
                benefit: "Weekly and monthly trend charts"
            )
        case .libraryFilters:
            return UpgradePrompt(
                title: "Find exercises faster",
                description: "Filter by time, difficulty, equipment, and focus area.",
                benefit: "Advanced library search"
            )
        case .unlimitedSessions:
            return UpgradePrompt(
                title: "Unlimited daily resets",
                description: "Access all your daily sessions, not just the first one.",
                benefit: "No session limits"
            )
        }
    }
}

// MARK: - Upgrade Prompt

/// Data for displaying upgrade prompts to users
struct UpgradePrompt {
    let title: String
    let description: String
    let benefit: String

    /// Short CTA text
    var ctaText: String { "See Pro" }

    /// Full CTA text
    var fullCTA: String { "Upgrade to Pro" }
}

// MARK: - Quick Access Helpers

extension FeatureGate {
    /// Get a summary of what's available in the free tier
    static let freeTierSummary = """
    • Today's summary & score
    • 1 daily reset session
    • 7 days of progress history
    • Basic exercise library
    """

    /// Get a summary of Pro tier benefits
    static let proTierBenefits = """
    • Full 7-day personalized plan
    • Unlimited daily sessions
    • Advanced progress insights
    • Smart reminders & nudges
    • Complete exercise library
    • Monthly progress history
    """
}
