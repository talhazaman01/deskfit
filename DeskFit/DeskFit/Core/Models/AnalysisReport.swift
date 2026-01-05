import Foundation

// MARK: - Analysis Report

/// Personalized posture analysis report generated from onboarding answers.
/// Stored locally for revisiting in Profile > My Plan > "Your Assessment".
struct AnalysisReport: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let createdAt: Date

    // MARK: - Summary

    /// Main headline (1-2 lines) e.g., "Your desk habits are creating tension buildup"
    let summaryHeadline: String

    /// Supporting body text (2-3 sentences)
    let summaryBody: String

    /// Overall posture/stiffness load score
    let score: AnalysisScore

    // MARK: - Detailed Analysis

    /// 3-6 personalized insight cards
    let insights: [InsightCard]

    /// 4-8 risk factor bullets derived from profile inputs
    let riskFactors: [String]

    /// Focus areas from pain/posture issues (used for chips display)
    let focusAreas: [String]

    /// Recommended priorities for the plan (e.g., "Neck mobility", "Upper-back activation")
    let recommendedPriorities: [String]

    /// What we'll do this week bullets (ties into 7-day plan)
    let weeklyActions: [String]

    /// Legal/safety disclaimers
    let disclaimers: [String]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        summaryHeadline: String,
        summaryBody: String,
        score: AnalysisScore,
        insights: [InsightCard],
        riskFactors: [String],
        focusAreas: [String],
        recommendedPriorities: [String],
        weeklyActions: [String],
        disclaimers: [String] = AnalysisReport.defaultDisclaimers
    ) {
        self.id = id
        self.createdAt = createdAt
        self.summaryHeadline = summaryHeadline
        self.summaryBody = summaryBody
        self.score = score
        self.insights = insights
        self.riskFactors = riskFactors
        self.focusAreas = focusAreas
        self.recommendedPriorities = recommendedPriorities
        self.weeklyActions = weeklyActions
        self.disclaimers = disclaimers
    }

    // MARK: - Default Disclaimers

    static let defaultDisclaimers: [String] = [
        "This assessment is based on your self-reported answers and is not a medical diagnosis.",
        "Consult a healthcare professional if you experience persistent pain or discomfort.",
        "Results are meant to guide your movement routine, not replace professional advice."
    ]
}

// MARK: - Analysis Score

/// Score from 0-100 with category labels
struct AnalysisScore: Codable, Hashable, Sendable {
    let value: Int
    let category: ScoreCategory

    init(value: Int) {
        self.value = max(0, min(100, value))
        self.category = ScoreCategory.from(score: self.value)
    }

    /// Display percentage string
    var displayValue: String {
        "\(value)"
    }

    /// Color indicator based on category
    var categoryLabel: String {
        category.displayName
    }
}

// MARK: - Score Category

enum ScoreCategory: String, Codable, Hashable, Sendable {
    case low
    case moderate
    case elevated

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .elevated: return "Elevated"
        }
    }

    var description: String {
        switch self {
        case .low:
            return "Your current habits show lower risk factors for desk-related discomfort."
        case .moderate:
            return "Your routine has some patterns commonly linked with stiffness and tension."
        case .elevated:
            return "Your answers suggest higher likelihood of desk-related discomfort building up."
        }
    }

    static func from(score: Int) -> ScoreCategory {
        switch score {
        case 0...33: return .low
        case 34...66: return .moderate
        default: return .elevated
        }
    }
}

// MARK: - Insight Card

/// A single insight card shown in the analysis report
struct InsightCard: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let body: String
    let severity: Severity
    let actionLabel: String
    let tags: [String]
    let icon: String

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        severity: Severity,
        actionLabel: String,
        tags: [String] = [],
        icon: String = "lightbulb.fill"
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.severity = severity
        self.actionLabel = actionLabel
        self.tags = tags
        self.icon = icon
    }
}

// MARK: - Severity

enum Severity: String, Codable, Hashable, Sendable {
    case low
    case medium
    case high

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

// MARK: - Insight Type (Internal use for generation)

enum InsightType: String, CaseIterable {
    case sedentaryLoad
    case stiffnessTiming
    case neckUpperBack
    case lowerBackHips
    case recovery
    case movementBaseline
    case timeEfficiency
    case workContext

    var icon: String {
        switch self {
        case .sedentaryLoad: return "chair.fill"
        case .stiffnessTiming: return "clock.fill"
        case .neckUpperBack: return "figure.stand"
        case .lowerBackHips: return "figure.walk"
        case .recovery: return "moon.fill"
        case .movementBaseline: return "figure.run"
        case .timeEfficiency: return "timer"
        case .workContext: return "desktopcomputer"
        }
    }
}
