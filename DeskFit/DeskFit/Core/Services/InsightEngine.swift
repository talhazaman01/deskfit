import Foundation

// MARK: - Daily Insight Model

/// A personalized insight shown to the user
struct DailyInsight: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let category: InsightCategory
    let title: String
    let body: String
    let badge: String?
    let ctaText: String?
    let debugTags: [String]
    let generatedAt: Date

    init(
        id: UUID = UUID(),
        category: InsightCategory,
        title: String,
        body: String,
        badge: String? = nil,
        ctaText: String? = nil,
        debugTags: [String] = [],
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.body = body
        self.badge = badge
        self.ctaText = ctaText
        self.debugTags = debugTags
        self.generatedAt = generatedAt
    }
}

// MARK: - Insight Category

enum InsightCategory: String, Codable, CaseIterable, Sendable {
    case painSpecific
    case sedentaryRisk
    case stiffnessTiming
    case progressTip
    case planTip
    case motivational
    case recovery
    case workEnvironment

    var displayName: String {
        switch self {
        case .painSpecific: return "Pain Relief"
        case .sedentaryRisk: return "Movement"
        case .stiffnessTiming: return "Timing"
        case .progressTip: return "Progress"
        case .planTip: return "Today's Focus"
        case .motivational: return "Motivation"
        case .recovery: return "Recovery"
        case .workEnvironment: return "Work Wellness"
        }
    }

    var icon: String {
        switch self {
        case .painSpecific: return "bandage"
        case .sedentaryRisk: return "figure.walk"
        case .stiffnessTiming: return "clock"
        case .progressTip: return "chart.line.uptrend.xyaxis"
        case .planTip: return "calendar"
        case .motivational: return "sparkles"
        case .recovery: return "moon.stars"
        case .workEnvironment: return "desktopcomputer"
        }
    }
}

// MARK: - Insight Engine

/// Engine for generating personalized, varied daily insights.
/// Uses deterministic selection based on date + user inputs to ensure consistency.
@MainActor
final class InsightEngine {

    static let shared = InsightEngine()

    // MARK: - Persistence Keys

    private enum Keys {
        static let todaysInsights = "insight_engine_todays_insights"
        static let lastGeneratedDate = "insight_engine_last_generated_date"
    }

    // MARK: - Cached State

    private var cachedInsights: [DailyInsight] = []
    private var cachedDate: Date?

    private init() {
        loadCachedInsights()
    }

    // MARK: - Public API

    /// Get today's insights. Regenerates if it's a new day.
    func getTodaysInsights(
        profile: OnboardingProfileSnapshot?,
        progressSummary: ProgressSummary?,
        todaysPlan: DailyPlanItem?
    ) -> [DailyInsight] {
        let today = Calendar.current.startOfDay(for: Date())

        // Check if we already generated for today
        if let cachedDate = cachedDate,
           Calendar.current.isDate(cachedDate, inSameDayAs: today),
           !cachedInsights.isEmpty {
            return cachedInsights
        }

        // Generate new insights for today
        let insights = generateInsights(
            profile: profile,
            progressSummary: progressSummary,
            todaysPlan: todaysPlan,
            date: today
        )

        // Cache and persist
        cachedInsights = insights
        cachedDate = today
        persistInsights()

        return insights
    }

    /// Force regenerate insights (for testing or refresh)
    func regenerateInsights(
        profile: OnboardingProfileSnapshot?,
        progressSummary: ProgressSummary?,
        todaysPlan: DailyPlanItem?
    ) -> [DailyInsight] {
        cachedDate = nil
        return getTodaysInsights(
            profile: profile,
            progressSummary: progressSummary,
            todaysPlan: todaysPlan
        )
    }

    // MARK: - Generation Logic

    private func generateInsights(
        profile: OnboardingProfileSnapshot?,
        progressSummary: ProgressSummary?,
        todaysPlan: DailyPlanItem?,
        date: Date
    ) -> [DailyInsight] {
        var insights: [DailyInsight] = []
        var usedCategories: Set<InsightCategory> = []

        // Create a deterministic seed based on date and profile
        let seed = createSeed(date: date, profile: profile)

        // 1. Primary insight - always personalized based on user data
        if let primaryInsight = generatePrimaryInsight(profile: profile, progressSummary: progressSummary, seed: seed) {
            insights.append(primaryInsight)
            usedCategories.insert(primaryInsight.category)
        }

        // 2. Secondary insight - rotated category based on day of week
        if let secondaryInsight = generateSecondaryInsight(
            profile: profile,
            progressSummary: progressSummary,
            todaysPlan: todaysPlan,
            usedCategories: usedCategories,
            seed: seed
        ) {
            insights.append(secondaryInsight)
            usedCategories.insert(secondaryInsight.category)
        }

        // 3. Optional third insight for Pro users or high-engagement days
        if let tertiaryInsight = generateTertiaryInsight(
            profile: profile,
            progressSummary: progressSummary,
            usedCategories: usedCategories,
            seed: seed
        ) {
            insights.append(tertiaryInsight)
        }

        // Track analytics
        for insight in insights {
            let personaHash = createPersonaHash(profile: profile)
            AnalyticsService.shared.track(.insightGenerated(
                category: insight.category.rawValue,
                personaHash: personaHash
            ))
        }

        return insights
    }

    // MARK: - Primary Insight Generation

    private func generatePrimaryInsight(
        profile: OnboardingProfileSnapshot?,
        progressSummary: ProgressSummary?,
        seed: Int
    ) -> DailyInsight? {
        guard let profile = profile else {
            return motivationalInsight(seed: seed)
        }

        let painAreas = profile.painAreasEnum
        let stiffnessTimes = profile.stiffnessTimesEnum
        let sedentaryBucket = profile.sedentaryHoursBucketEnum

        // Choose based on what the user has reported
        if !painAreas.isEmpty {
            return painSpecificInsight(
                painAreas: painAreas,
                sedentaryBucket: sedentaryBucket,
                seed: seed
            )
        } else if let bucket = sedentaryBucket, bucket.isHighRisk {
            return sedentaryRiskInsight(
                bucket: bucket,
                stiffnessTimes: stiffnessTimes,
                seed: seed
            )
        } else if !stiffnessTimes.isEmpty {
            return stiffnessTimingInsight(
                stiffnessTimes: stiffnessTimes,
                profile: profile,
                seed: seed
            )
        }

        return motivationalInsight(seed: seed)
    }

    // MARK: - Secondary Insight Generation

    private func generateSecondaryInsight(
        profile: OnboardingProfileSnapshot?,
        progressSummary: ProgressSummary?,
        todaysPlan: DailyPlanItem?,
        usedCategories: Set<InsightCategory>,
        seed: Int
    ) -> DailyInsight? {
        // Rotate through categories based on day of week
        let dayOfWeek = Calendar.current.component(.weekday, from: Date())
        let rotationCategories: [InsightCategory] = [
            .progressTip, .planTip, .motivational, .recovery,
            .workEnvironment, .sedentaryRisk, .stiffnessTiming
        ]

        let categoryIndex = (dayOfWeek + seed) % rotationCategories.count
        var selectedCategory = rotationCategories[categoryIndex]

        // Skip if already used
        if usedCategories.contains(selectedCategory) {
            selectedCategory = rotationCategories[(categoryIndex + 1) % rotationCategories.count]
        }

        switch selectedCategory {
        case .progressTip:
            return progressInsight(summary: progressSummary, seed: seed)
        case .planTip:
            return planInsight(todaysPlan: todaysPlan, profile: profile, seed: seed)
        case .motivational:
            return motivationalInsight(seed: seed)
        case .recovery:
            return recoveryInsight(profile: profile, seed: seed)
        case .workEnvironment:
            return workEnvironmentInsight(profile: profile, seed: seed)
        default:
            return motivationalInsight(seed: seed)
        }
    }

    // MARK: - Tertiary Insight Generation

    private func generateTertiaryInsight(
        profile: OnboardingProfileSnapshot?,
        progressSummary: ProgressSummary?,
        usedCategories: Set<InsightCategory>,
        seed: Int
    ) -> DailyInsight? {
        // Only generate third insight for users with streak > 3 or high engagement
        guard let summary = progressSummary,
              summary.streakDays >= 3 || summary.weeklySessionsCompleted >= 5 else {
            return nil
        }

        // Choose an unused motivational or recovery insight
        if !usedCategories.contains(.motivational) {
            return motivationalInsight(seed: seed + 100)
        } else if !usedCategories.contains(.recovery) {
            return recoveryInsight(profile: profile, seed: seed)
        }

        return nil
    }

    // MARK: - Category-Specific Generators

    private func painSpecificInsight(
        painAreas: Set<PainArea>,
        sedentaryBucket: SedentaryHoursBucket?,
        seed: Int
    ) -> DailyInsight {
        let templates = PainInsightTemplates.all
        let templateIndex = seed % templates.count
        let template = templates[templateIndex]

        // Personalize based on pain areas
        let primaryPain = painAreas.first ?? .neck
        let sedentaryContext = sedentaryBucket?.displayName ?? "desk time"

        let body = template.body
            .replacingOccurrences(of: "{pain_area}", with: primaryPain.displayName.lowercased())
            .replacingOccurrences(of: "{sedentary}", with: sedentaryContext)

        return DailyInsight(
            category: .painSpecific,
            title: template.title.replacingOccurrences(of: "{pain_area}", with: primaryPain.displayName),
            body: body,
            badge: template.badge,
            ctaText: template.cta,
            debugTags: ["pain_\(primaryPain.rawValue)", "template_\(templateIndex)"]
        )
    }

    private func sedentaryRiskInsight(
        bucket: SedentaryHoursBucket,
        stiffnessTimes: Set<StiffnessTime>,
        seed: Int
    ) -> DailyInsight {
        let templates = SedentaryInsightTemplates.all
        let templateIndex = seed % templates.count
        let template = templates[templateIndex]

        let timingContext = stiffnessTimes.isEmpty
            ? "throughout the day"
            : stiffnessTimes.map { $0.displayName.lowercased() }.joined(separator: " and ")

        let body = template.body
            .replacingOccurrences(of: "{hours}", with: bucket.displayName)
            .replacingOccurrences(of: "{timing}", with: timingContext)

        return DailyInsight(
            category: .sedentaryRisk,
            title: template.title,
            body: body,
            badge: template.badge,
            ctaText: template.cta,
            debugTags: ["sedentary_\(bucket.rawValue)", "template_\(templateIndex)"]
        )
    }

    private func stiffnessTimingInsight(
        stiffnessTimes: Set<StiffnessTime>,
        profile: OnboardingProfileSnapshot,
        seed: Int
    ) -> DailyInsight {
        let templates = StiffnessInsightTemplates.all
        let templateIndex = seed % templates.count
        let template = templates[templateIndex]

        let primaryTime = stiffnessTimes.first ?? .morning
        let focusAreas = profile.focusAreasEnum.prefix(2).map { $0.displayName.lowercased() }
        let focusContext = focusAreas.joined(separator: " and ")

        let body = template.body
            .replacingOccurrences(of: "{time}", with: primaryTime.displayName.lowercased())
            .replacingOccurrences(of: "{focus}", with: focusContext.isEmpty ? "your target areas" : focusContext)

        return DailyInsight(
            category: .stiffnessTiming,
            title: template.title.replacingOccurrences(of: "{time}", with: primaryTime.displayName),
            body: body,
            badge: template.badge,
            ctaText: template.cta,
            debugTags: ["stiffness_\(primaryTime.rawValue)", "template_\(templateIndex)"]
        )
    }

    private func progressInsight(summary: ProgressSummary?, seed: Int) -> DailyInsight {
        let templates = ProgressInsightTemplates.all
        var templateIndex = seed % templates.count

        // Select template based on user's progress state
        if let summary = summary {
            if summary.trend == .improving {
                templateIndex = seed % ProgressInsightTemplates.improving.count
                let template = ProgressInsightTemplates.improving[templateIndex]
                return buildProgressInsight(template: template, summary: summary, seed: seed)
            } else if summary.streakDays >= 3 {
                templateIndex = seed % ProgressInsightTemplates.streak.count
                let template = ProgressInsightTemplates.streak[templateIndex]
                return buildProgressInsight(template: template, summary: summary, seed: seed)
            } else if summary.weeklySessionsCompleted == 0 {
                templateIndex = seed % ProgressInsightTemplates.restart.count
                let template = ProgressInsightTemplates.restart[templateIndex]
                return buildProgressInsight(template: template, summary: summary, seed: seed)
            }
        }

        let template = templates[templateIndex]
        return buildProgressInsight(template: template, summary: summary, seed: seed)
    }

    private func buildProgressInsight(template: InsightTemplate, summary: ProgressSummary?, seed: Int) -> DailyInsight {
        let streak = summary?.streakDays ?? 0
        let sessions = summary?.weeklySessionsCompleted ?? 0
        let score = summary?.weeklyAverageScore ?? 0

        let body = template.body
            .replacingOccurrences(of: "{streak}", with: "\(streak)")
            .replacingOccurrences(of: "{sessions}", with: "\(sessions)")
            .replacingOccurrences(of: "{score}", with: "\(score)")

        return DailyInsight(
            category: .progressTip,
            title: template.title,
            body: body,
            badge: template.badge,
            ctaText: template.cta,
            debugTags: ["progress", "template_\(seed % 10)"]
        )
    }

    private func planInsight(todaysPlan: DailyPlanItem?, profile: OnboardingProfileSnapshot?, seed: Int) -> DailyInsight {
        let templates = PlanInsightTemplates.all
        let templateIndex = seed % templates.count
        let template = templates[templateIndex]

        let sessionCount = todaysPlan?.sessionCount ?? 3
        let focusAreas = profile?.focusAreasEnum.prefix(2).map { $0.displayName.lowercased() } ?? ["your focus areas"]
        let focusContext = focusAreas.joined(separator: " and ")

        let body = template.body
            .replacingOccurrences(of: "{session_count}", with: "\(sessionCount)")
            .replacingOccurrences(of: "{focus}", with: focusContext)

        return DailyInsight(
            category: .planTip,
            title: template.title,
            body: body,
            badge: template.badge,
            ctaText: template.cta,
            debugTags: ["plan", "template_\(templateIndex)"]
        )
    }

    private func motivationalInsight(seed: Int) -> DailyInsight {
        let templates = MotivationalInsightTemplates.all
        let templateIndex = seed % templates.count
        let template = templates[templateIndex]

        return DailyInsight(
            category: .motivational,
            title: template.title,
            body: template.body,
            badge: template.badge,
            ctaText: template.cta,
            debugTags: ["motivational", "template_\(templateIndex)"]
        )
    }

    private func recoveryInsight(profile: OnboardingProfileSnapshot?, seed: Int) -> DailyInsight {
        let templates = RecoveryInsightTemplates.all
        let templateIndex = seed % templates.count
        let template = templates[templateIndex]

        return DailyInsight(
            category: .recovery,
            title: template.title,
            body: template.body,
            badge: template.badge,
            ctaText: template.cta,
            debugTags: ["recovery", "template_\(templateIndex)"]
        )
    }

    private func workEnvironmentInsight(profile: OnboardingProfileSnapshot?, seed: Int) -> DailyInsight {
        let templates = WorkEnvironmentInsightTemplates.all
        let templateIndex = seed % templates.count
        let template = templates[templateIndex]

        let workType = profile?.workTypeEnum?.displayName ?? "your desk"

        let body = template.body
            .replacingOccurrences(of: "{work_type}", with: workType.lowercased())

        return DailyInsight(
            category: .workEnvironment,
            title: template.title,
            body: body,
            badge: template.badge,
            ctaText: template.cta,
            debugTags: ["work_environment", "template_\(templateIndex)"]
        )
    }

    // MARK: - Helpers

    private func createSeed(date: Date, profile: OnboardingProfileSnapshot?) -> Int {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let profileHash = profile?.hashValue ?? 0
        return abs(dayOfYear + profileHash) % 1000
    }

    private func createPersonaHash(profile: OnboardingProfileSnapshot?) -> String {
        guard let profile = profile else { return "unknown" }

        var components: [String] = []

        if !profile.painAreasEnum.isEmpty {
            components.append("pain_\(profile.painAreasEnum.count)")
        }
        if let bucket = profile.sedentaryHoursBucketEnum {
            components.append("sed_\(bucket.rawValue)")
        }
        if !profile.stiffnessTimesEnum.isEmpty {
            components.append("stiff_\(profile.stiffnessTimesEnum.count)")
        }

        return components.joined(separator: "_")
    }

    // MARK: - Persistence

    private func loadCachedInsights() {
        guard let data = UserDefaults.standard.data(forKey: Keys.todaysInsights),
              let insights = try? JSONDecoder().decode([DailyInsight].self, from: data),
              let lastDate = UserDefaults.standard.object(forKey: Keys.lastGeneratedDate) as? Date else {
            return
        }

        cachedInsights = insights
        cachedDate = lastDate
    }

    private func persistInsights() {
        guard let data = try? JSONEncoder().encode(cachedInsights) else { return }
        UserDefaults.standard.set(data, forKey: Keys.todaysInsights)
        UserDefaults.standard.set(cachedDate, forKey: Keys.lastGeneratedDate)
    }
}

// MARK: - Sedentary Bucket Extension

extension SedentaryHoursBucket {
    var isHighRisk: Bool {
        self == .sixToEight || self == .moreThan8
    }
}

// MARK: - Insight Template

struct InsightTemplate {
    let title: String
    let body: String
    let badge: String?
    let cta: String?

    init(title: String, body: String, badge: String? = nil, cta: String? = nil) {
        self.title = title
        self.body = body
        self.badge = badge
        self.cta = cta
    }
}
