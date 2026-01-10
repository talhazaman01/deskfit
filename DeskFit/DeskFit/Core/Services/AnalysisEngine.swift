import Foundation

/// Engine that generates personalized analysis reports from onboarding profile data.
/// All scoring is deterministic - same inputs always produce the same outputs.
final class AnalysisEngine: Sendable {
    static let shared = AnalysisEngine()

    private init() {}

    // MARK: - Public API

    /// Generate a complete analysis report from the user's onboarding profile
    func generate(profile: OnboardingProfileSnapshot) -> AnalysisReport {
        let score = calculateScore(from: profile)
        let insights = generateInsights(from: profile)
        let riskFactors = generateRiskFactors(from: profile)
        let focusAreas = deriveFocusAreas(from: profile)
        let recommendedPriorities = deriveRecommendedPriorities(from: profile)
        let weeklyActions = generateWeeklyActions(from: profile)
        let (headline, body) = generateSummary(score: score, profile: profile)

        return AnalysisReport(
            summaryHeadline: headline,
            summaryBody: body,
            score: score,
            insights: insights,
            riskFactors: riskFactors,
            focusAreas: focusAreas,
            recommendedPriorities: recommendedPriorities,
            weeklyActions: weeklyActions
        )
    }

    /// Generate a report from a UserProfile (convenience wrapper)
    func generate(from userProfile: UserProfile) -> AnalysisReport {
        let snapshot = OnboardingProfileSnapshot.from(profile: userProfile)
        return generate(profile: snapshot)
    }

    // MARK: - Scoring Logic

    /// Calculate the posture/stiffness load score (0-100)
    /// Higher score = higher load/risk factors
    func calculateScore(from profile: OnboardingProfileSnapshot) -> AnalysisScore {
        var totalPoints = 0
        var maxPoints = 0

        // 1. Sedentary hours (max 25 points)
        maxPoints += 25
        if let bucket = profile.sedentaryHoursBucketEnum {
            totalPoints += sedentaryHoursScore(bucket)
        } else {
            // Default to moderate if not provided
            totalPoints += 12
        }

        // 2. Stiffness spread (max 20 points)
        maxPoints += 20
        totalPoints += stiffnessSpreadScore(profile.stiffnessTimesEnum)

        // 3. Pain/discomfort areas count (max 20 points)
        maxPoints += 20
        totalPoints += painAreasScore(profile.painAreasEnum.count)

        // 4. Posture issues count (max 15 points)
        maxPoints += 15
        totalPoints += postureIssuesScore(profile.postureIssuesEnum.count)

        // 5. Exercise frequency (max 15 points - inverted, less exercise = more points)
        maxPoints += 15
        if let frequency = profile.exerciseFrequencyEnum {
            totalPoints += exerciseFrequencyScore(frequency)
        } else {
            // Default to moderate if not provided
            totalPoints += 8
        }

        // 6. Work hours contribution (max 5 points)
        maxPoints += 5
        totalPoints += workHoursScore(profile.workStartMinutes, profile.workEndMinutes)

        // Normalize to 0-100
        let normalizedScore = maxPoints > 0 ? (totalPoints * 100) / maxPoints : 50
        return AnalysisScore(value: normalizedScore)
    }

    // MARK: - Component Scores

    private func sedentaryHoursScore(_ bucket: SedentaryHoursBucket) -> Int {
        switch bucket {
        case .lessThan2: return 5
        case .twoToFour: return 10
        case .fourToSix: return 15
        case .sixToEight: return 20
        case .moreThan8: return 25
        }
    }

    private func stiffnessSpreadScore(_ times: Set<StiffnessTime>) -> Int {
        // More stiffness times = higher score
        switch times.count {
        case 0: return 5
        case 1: return 8
        case 2: return 14
        case 3: return 20 // All day stiffness
        default: return 20
        }
    }

    private func painAreasScore(_ count: Int) -> Int {
        // More pain areas = higher score
        switch count {
        case 0: return 0
        case 1: return 5
        case 2: return 10
        case 3: return 14
        case 4: return 17
        default: return 20
        }
    }

    private func postureIssuesScore(_ count: Int) -> Int {
        switch count {
        case 0: return 0
        case 1: return 4
        case 2: return 8
        case 3: return 11
        default: return 15
        }
    }

    private func exerciseFrequencyScore(_ frequency: ExerciseFrequency) -> Int {
        // Less exercise = higher score (more load)
        switch frequency {
        case .rarely: return 15
        case .onceWeek: return 12
        case .twoThreeWeek: return 8
        case .fourPlusWeek: return 4
        case .daily: return 2
        }
    }

    private func workHoursScore(_ startMinutes: Int, _ endMinutes: Int) -> Int {
        let workHours = (endMinutes - startMinutes) / 60
        switch workHours {
        case 0...6: return 1
        case 7...8: return 2
        case 9...10: return 4
        default: return 5
        }
    }

    // MARK: - Insight Generation

    func generateInsights(from profile: OnboardingProfileSnapshot) -> [InsightCard] {
        var insights: [InsightCard] = []

        // 1. Sedentary Load Insight
        if let sedentaryInsight = generateSedentaryLoadInsight(profile) {
            insights.append(sedentaryInsight)
        }

        // 2. Stiffness Timing Insight
        if let stiffnessInsight = generateStiffnessTimingInsight(profile) {
            insights.append(stiffnessInsight)
        }

        // 3. Neck/Upper Back Focus Insight
        if let neckInsight = generateNeckUpperBackInsight(profile) {
            insights.append(neckInsight)
        }

        // 4. Lower Back + Hips Insight
        if let lowerBackInsight = generateLowerBackHipsInsight(profile) {
            insights.append(lowerBackInsight)
        }

        // 5. Movement Baseline Insight
        if let movementInsight = generateMovementBaselineInsight(profile) {
            insights.append(movementInsight)
        }

        // 6. Time Efficiency Insight
        if let timeInsight = generateTimeEfficiencyInsight(profile) {
            insights.append(timeInsight)
        }

        // 7. Work Context Insight
        if let workInsight = generateWorkContextInsight(profile) {
            insights.append(workInsight)
        }

        // Sort by severity (high first), limit to 6
        let sortedInsights = insights.sorted { $0.severity.sortOrder < $1.severity.sortOrder }
        return Array(sortedInsights.prefix(6))
    }

    // MARK: - Individual Insight Generators

    /// Deterministic seed for template rotation - ensures same inputs produce same outputs,
    /// but different inputs get different templates
    private func templateSeed(for profile: OnboardingProfileSnapshot) -> Int {
        var hasher = Hasher()
        hasher.combine(profile.painAreas.sorted().joined())
        hasher.combine(profile.stiffnessTimes.sorted().joined())
        hasher.combine(profile.sedentaryHoursBucket)
        hasher.combine(profile.focusAreas.sorted().joined())
        return abs(hasher.finalize()) % 100
    }

    private func generateSedentaryLoadInsight(_ profile: OnboardingProfileSnapshot) -> InsightCard? {
        guard let bucket = profile.sedentaryHoursBucketEnum else { return nil }

        let isTrigger = bucket == .sixToEight || bucket == .moreThan8

        guard isTrigger else { return nil }

        let hoursText = bucket.displayName
        let severity: Severity = bucket == .moreThan8 ? .high : .medium
        let seed = templateSeed(for: profile)

        // Template rotation for variety
        let templates: [(title: String, body: String, action: String)] = [
            (
                "Sedentary Load",
                "Sitting \(hoursText)+ hours daily is commonly linked with increased muscle tension and reduced circulation. Regular movement breaks can help counteract these effects.",
                "We'll schedule micro-resets throughout your workday."
            ),
            (
                "Extended Sitting Pattern",
                "Your \(hoursText)+ hour desk days may contribute to the stiffness you're experiencing. Brief, targeted movements throughout the day often help.",
                "Your plan includes exercises timed for your work schedule."
            ),
            (
                "Desk Time Impact",
                "With \(hoursText)+ hours of daily sitting, muscle tension can accumulate gradually. Consistent movement breaks are often effective at managing this.",
                "We'll help you build a sustainable movement routine."
            )
        ]

        let template = templates[seed % templates.count]

        return InsightCard(
            title: template.title,
            body: template.body,
            severity: severity,
            actionLabel: template.action,
            tags: ["sedentary", "sitting", bucket.rawValue],
            icon: InsightType.sedentaryLoad.icon
        )
    }

    private func generateStiffnessTimingInsight(_ profile: OnboardingProfileSnapshot) -> InsightCard? {
        let times = profile.stiffnessTimesEnum
        guard times.count >= 2 else { return nil }

        let timeNames = times.sorted { $0.rawValue < $1.rawValue }.map { $0.displayName.lowercased() }
        let timesText = timeNames.joined(separator: " and ")

        let isAllDay = times.count == StiffnessTime.allCases.count
        let severity: Severity = isAllDay ? .high : .medium
        let seed = templateSeed(for: profile)

        let templates: [(title: String, bodyAllDay: String, bodyPartial: String, actionAllDay: String, actionPartial: String)] = [
            (
                "Stiffness Pattern",
                "You're experiencing stiffness throughout your entire day. This widespread pattern often correlates with prolonged sitting and limited movement variety.",
                "You feel stiffest during \(timesText). This timing pattern can help us target your exercises when they'll have the most impact.",
                "We'll spread exercises across your day for continuous relief.",
                "We'll prioritize sessions during your peak stiffness times."
            ),
            (
                "Your Stiffness Rhythm",
                "All-day stiffness suggests your body may need more frequent movement throughout your workday. Small, consistent breaks often help.",
                "Your \(timesText) stiffness pattern tells us when your body most needs movement. We'll time your resets accordingly.",
                "Your plan includes exercises distributed throughout the day.",
                "Sessions are timed for when you typically feel most tense."
            ),
            (
                "Timing Matters",
                "Feeling stiff all day indicates tension is accumulating faster than it's releasing. More frequent micro-movements can help break this cycle.",
                "The \(timesText) stiffness you mentioned points to specific windows where movement can be most beneficial.",
                "We'll help you build movement habits for every part of your day.",
                "Your resets are scheduled for maximum impact."
            )
        ]

        let template = templates[seed % templates.count]

        return InsightCard(
            title: template.title,
            body: isAllDay ? template.bodyAllDay : template.bodyPartial,
            severity: severity,
            actionLabel: isAllDay ? template.actionAllDay : template.actionPartial,
            tags: ["stiffness", "timing"] + times.map { $0.rawValue },
            icon: InsightType.stiffnessTiming.icon
        )
    }

    private func generateNeckUpperBackInsight(_ profile: OnboardingProfileSnapshot) -> InsightCard? {
        let painAreas = profile.painAreasEnum
        let postureIssues = profile.postureIssuesEnum

        let hasNeckPain = painAreas.contains(.neck)
        let hasShoulderPain = painAreas.contains(.shoulders)
        let hasUpperBackPain = painAreas.contains(.upperBack)
        let hasHeadaches = painAreas.contains(.headaches)
        let hasForwardHead = postureIssues.contains(.forwardHead)
        let hasTextNeck = postureIssues.contains(.textNeck)
        let hasRoundedShoulders = postureIssues.contains(.roundedShoulders)

        let triggers = [hasNeckPain, hasShoulderPain, hasUpperBackPain, hasHeadaches, hasForwardHead, hasTextNeck, hasRoundedShoulders]
        let triggerCount = triggers.filter { $0 }.count

        guard triggerCount >= 1 else { return nil }

        let severity: Severity
        switch triggerCount {
        case 1: severity = .low
        case 2...3: severity = .medium
        default: severity = .high
        }

        var concerns: [String] = []
        if hasNeckPain { concerns.append("neck discomfort") }
        if hasShoulderPain { concerns.append("shoulder tension") }
        if hasUpperBackPain { concerns.append("upper back stiffness") }
        if hasForwardHead || hasTextNeck { concerns.append("forward head positioning") }
        if hasRoundedShoulders { concerns.append("rounded shoulders") }
        if hasHeadaches { concerns.append("tension headaches") }

        let concernsText = concerns.prefix(2).joined(separator: " and ")
        let seed = templateSeed(for: profile)

        let templates: [(title: String, body: String, action: String)] = [
            (
                "Neck & Upper Back Focus",
                "Your \(concernsText) may be connected to desk posture habits. These areas often benefit from targeted mobility and strengthening exercises.",
                "We'll include specific neck and upper back exercises in your plan."
            ),
            (
                "Upper Body Attention",
                "The \(concernsText) you mentioned is common among desk workers. Gentle, consistent movement can help address the underlying tension patterns.",
                "Your plan prioritizes exercises for these key areas."
            ),
            (
                "Targeting Your Tension",
                "Screen time and desk positioning often contribute to \(concernsText). Regular mobility work can help maintain comfort throughout your day.",
                "We've designed exercises specifically for your upper body needs."
            )
        ]

        let template = templates[seed % templates.count]

        return InsightCard(
            title: template.title,
            body: template.body,
            severity: severity,
            actionLabel: template.action,
            tags: ["neck", "upper_back", "shoulders", "posture"],
            icon: InsightType.neckUpperBack.icon
        )
    }

    private func generateLowerBackHipsInsight(_ profile: OnboardingProfileSnapshot) -> InsightCard? {
        let painAreas = profile.painAreasEnum
        let postureIssues = profile.postureIssuesEnum
        let sedentaryBucket = profile.sedentaryHoursBucketEnum

        let hasLowerBackPain = painAreas.contains(.lowerBack)
        let hasHipPain = painAreas.contains(.hips)
        let hasUnevenHips = postureIssues.contains(.unevenHips)
        let hasPelvicTilt = postureIssues.contains(.anteriorPelvicTilt)
        let hasSlouching = postureIssues.contains(.slouching)
        let isHighSedentary = sedentaryBucket == .moreThan8

        let triggers = [hasLowerBackPain, hasHipPain, hasUnevenHips, hasPelvicTilt, hasSlouching && isHighSedentary]
        let triggerCount = triggers.filter { $0 }.count

        guard triggerCount >= 1 else { return nil }

        let severity: Severity
        switch triggerCount {
        case 1: severity = .low
        case 2: severity = .medium
        default: severity = .high
        }

        var concerns: [String] = []
        if hasLowerBackPain { concerns.append("lower back discomfort") }
        if hasHipPain { concerns.append("hip tightness") }
        if hasUnevenHips { concerns.append("uneven hips") }
        if hasPelvicTilt { concerns.append("pelvic positioning") }

        let concernsText = concerns.isEmpty ? "lower body tension" : concerns.prefix(2).joined(separator: " and ")

        return InsightCard(
            title: "Lower Back & Hips",
            body: "Your \(concernsText) can be influenced by prolonged sitting. Hip flexors often tighten while glutes weaken, creating imbalances that affect the lower back.",
            severity: severity,
            actionLabel: "We'll add hip mobility and lower back relief exercises.",
            tags: ["lower_back", "hips", "mobility"],
            icon: InsightType.lowerBackHips.icon
        )
    }

    private func generateMovementBaselineInsight(_ profile: OnboardingProfileSnapshot) -> InsightCard? {
        guard let frequency = profile.exerciseFrequencyEnum else { return nil }

        let isTrigger = frequency == .rarely || frequency == .onceWeek

        guard isTrigger else { return nil }

        let severity: Severity = frequency == .rarely ? .medium : .low

        let body: String
        if frequency == .rarely {
            body = "Starting from a lower activity baseline means your body may respond quickly to consistent movement. We'll start gentle and build progressively."
        } else {
            body = "With once-weekly activity, adding daily micro-movements can help maintain flexibility between your regular workouts."
        }

        return InsightCard(
            title: "Movement Baseline",
            body: body,
            severity: severity,
            actionLabel: "We'll start with approachable exercises and progress as you build consistency.",
            tags: ["exercise", "baseline", frequency.rawValue],
            icon: InsightType.movementBaseline.icon
        )
    }

    private func generateTimeEfficiencyInsight(_ profile: OnboardingProfileSnapshot) -> InsightCard? {
        guard profile.dailyTimeMinutes <= 5 else { return nil }

        return InsightCard(
            title: "Time-Efficient Approach",
            body: "You've got \(profile.dailyTimeMinutes) minutes to work with. Research suggests even brief, consistent movement breaks can help reduce stiffness and improve focus.",
            severity: .low,
            actionLabel: "We'll design quick, focused sessions that fit your schedule.",
            tags: ["time", "efficiency", "micro_sessions"],
            icon: InsightType.timeEfficiency.icon
        )
    }

    private func generateWorkContextInsight(_ profile: OnboardingProfileSnapshot) -> InsightCard? {
        guard let workType = profile.workTypeEnum else { return nil }

        let body: String
        let actionLabel: String

        switch workType {
        case .deskOffice:
            body = "Office desk work often means less control over your environment and potentially more screen time. Your plan will include exercises suitable for an office setting."
            actionLabel = "We'll focus on discreet, desk-friendly movements."
        case .deskHome:
            body = "Working from home can blur boundaries between work and rest. Your setup flexibility is an advantage—we can include exercises that use your space effectively."
            actionLabel = "We'll include exercises you can do right at your desk."
        case .hybrid:
            body = "Switching between locations means varying setups and routines. Consistent movement habits can help maintain comfort across both environments."
            actionLabel = "We'll create a routine that works in any setting."
        case .standing:
            body = "Standing desks are great for reducing sitting time, but static standing creates its own patterns. We'll balance your routine accordingly."
            actionLabel = "We'll include exercises for standing desk users."
        case .mixed:
            body = "Moving between desk work and other activities means varied physical demands. Your routine will complement this variety."
            actionLabel = "We'll design a flexible routine for your active workday."
        }

        return InsightCard(
            title: "Work Environment",
            body: body,
            severity: .low,
            actionLabel: actionLabel,
            tags: ["work", workType.rawValue],
            icon: InsightType.workContext.icon
        )
    }

    // MARK: - Risk Factors Generation

    func generateRiskFactors(from profile: OnboardingProfileSnapshot) -> [String] {
        var factors: [String] = []

        // Sedentary hours
        if let bucket = profile.sedentaryHoursBucketEnum {
            switch bucket {
            case .moreThan8:
                factors.append("Sitting 8+ hours daily can contribute to muscle tension and reduced circulation")
            case .sixToEight:
                factors.append("6-8 hours of daily sitting may increase likelihood of stiffness buildup")
            case .fourToSix:
                factors.append("4-6 hours of sitting is common but benefits from regular movement breaks")
            default:
                break
            }
        }

        // Stiffness patterns
        let stiffnessTimes = profile.stiffnessTimesEnum
        if stiffnessTimes.count == StiffnessTime.allCases.count {
            factors.append("All-day stiffness pattern often correlates with limited movement variety")
        } else if stiffnessTimes.count == 2 {
            factors.append("Stiffness at multiple times of day may indicate cumulative tension")
        }

        // Pain areas
        let painAreas = profile.painAreasEnum
        if painAreas.contains(.neck) {
            factors.append("Neck discomfort is commonly linked with screen positioning and forward head posture")
        }
        if painAreas.contains(.lowerBack) {
            factors.append("Lower back discomfort may correlate with prolonged sitting and hip tightness")
        }
        if painAreas.contains(.shoulders) {
            factors.append("Shoulder tension often develops from keyboard and mouse positioning")
        }
        if painAreas.contains(.wrists) {
            factors.append("Wrist strain can result from repetitive typing and mouse movements")
        }
        if painAreas.contains(.headaches) {
            factors.append("Tension headaches may be connected to neck and shoulder tightness")
        }

        // Posture issues
        let postureIssues = profile.postureIssuesEnum
        if postureIssues.contains(.forwardHead) || postureIssues.contains(.textNeck) {
            factors.append("Forward head posture can increase strain on neck muscles")
        }
        if postureIssues.contains(.roundedShoulders) {
            factors.append("Rounded shoulders may contribute to upper back and chest tightness")
        }
        if postureIssues.contains(.slouching) {
            factors.append("Slouching patterns often lead to reduced core engagement and back support")
        }
        if postureIssues.contains(.anteriorPelvicTilt) {
            factors.append("Anterior pelvic tilt can affect lower back comfort during sitting")
        }

        // Exercise frequency
        if let frequency = profile.exerciseFrequencyEnum {
            switch frequency {
            case .rarely:
                factors.append("Limited regular exercise may reduce muscle support for desk posture")
            case .onceWeek:
                factors.append("Once-weekly activity may not fully offset daily sitting effects")
            default:
                break
            }
        }

        // Work hours
        let workHours = (profile.workEndMinutes - profile.workStartMinutes) / 60
        if workHours >= 10 {
            factors.append("Extended work hours (\(workHours)+ hours) increase cumulative sitting time")
        }

        return Array(factors.prefix(8))
    }

    // MARK: - Focus Areas

    func deriveFocusAreas(from profile: OnboardingProfileSnapshot) -> [String] {
        var areas: Set<String> = []

        // From pain areas
        for painArea in profile.painAreasEnum {
            areas.insert(painArea.displayName)
        }

        // From posture issues (map to readable names)
        for issue in profile.postureIssuesEnum {
            areas.insert(issue.displayName)
        }

        // From explicitly selected focus areas
        for focusArea in profile.focusAreasEnum {
            areas.insert(focusArea.displayName)
        }

        return Array(areas).sorted()
    }

    // MARK: - Recommended Priorities

    func deriveRecommendedPriorities(from profile: OnboardingProfileSnapshot) -> [String] {
        var priorities: [String] = []

        let painAreas = profile.painAreasEnum
        let postureIssues = profile.postureIssuesEnum

        // Neck mobility
        if painAreas.contains(.neck) || postureIssues.contains(.forwardHead) || postureIssues.contains(.textNeck) {
            priorities.append("Neck mobility")
        }

        // Shoulder opening
        if painAreas.contains(.shoulders) || postureIssues.contains(.roundedShoulders) {
            priorities.append("Shoulder opening")
        }

        // Upper back activation
        if painAreas.contains(.upperBack) || postureIssues.contains(.slouching) {
            priorities.append("Upper back activation")
        }

        // Hip flexor stretching
        if painAreas.contains(.hips) || postureIssues.contains(.anteriorPelvicTilt) {
            priorities.append("Hip flexor stretching")
        }

        // Lower back relief
        if painAreas.contains(.lowerBack) || postureIssues.contains(.unevenHips) {
            priorities.append("Lower back relief")
        }

        // Wrist mobility
        if painAreas.contains(.wrists) {
            priorities.append("Wrist mobility")
        }

        // Default priorities if none specific
        if priorities.isEmpty {
            priorities = ["General mobility", "Posture awareness", "Movement breaks"]
        }

        return Array(priorities.prefix(4))
    }

    // MARK: - Weekly Actions

    func generateWeeklyActions(from profile: OnboardingProfileSnapshot) -> [String] {
        var actions: [String] = []

        let sessionsPerDay = profile.sessionsPerDay
        let sessionWord = sessionsPerDay == 1 ? "session" : "sessions"

        // Session structure
        actions.append("\(sessionsPerDay) quick \(sessionWord) per day, \(profile.dailyTimeMinutes) minutes total")

        // Stiffness timing
        let stiffnessTimes = profile.stiffnessTimesEnum
        if !stiffnessTimes.isEmpty {
            if stiffnessTimes.count == StiffnessTime.allCases.count {
                actions.append("Exercises spread throughout your day for all-day relief")
            } else {
                let times = stiffnessTimes.sorted { $0.rawValue < $1.rawValue }.map { $0.displayName.lowercased() }
                actions.append("Sessions timed for your \(times.joined(separator: " and ")) stiffness")
            }
        }

        // Focus areas
        let focusAreas = profile.focusAreasEnum
        if !focusAreas.isEmpty {
            let topAreas = focusAreas.prefix(2).map { $0.displayName.lowercased() }
            actions.append("Targeted exercises for your \(topAreas.joined(separator: " and "))")
        }

        // Progression
        if let motivation = profile.motivationLevelEnum {
            switch motivation {
            case .curious:
                actions.append("Gentle progression as you build your routine")
            case .ready:
                actions.append("Steady progression through the week")
            case .veryMotivated:
                actions.append("Progressive challenge to match your motivation")
            }
        } else {
            actions.append("Progressive exercises that build throughout the week")
        }

        return Array(actions.prefix(4))
    }

    // MARK: - Summary Generation

    func generateSummary(score: AnalysisScore, profile: OnboardingProfileSnapshot) -> (headline: String, body: String) {
        let headline: String
        let body: String

        switch score.category {
        case .low:
            headline = "Your desk habits show lower risk factors"
            body = "Based on your answers, you have a solid foundation. Our plan will help you maintain good habits and address any specific areas you'd like to improve."

        case .moderate:
            headline = "Your routine has patterns worth addressing"
            body = "Your answers reveal some common desk-related patterns that can contribute to stiffness over time. The good news? Targeted micro-movements can make a real difference."

        case .elevated:
            headline = "Your habits suggest room for improvement"
            body = "Based on what you've shared, your daily patterns may be contributing to the discomfort you're experiencing. A consistent movement routine can help address these factors."
        }

        return (headline, body)
    }
}

// MARK: - Mock Data for Previews

extension AnalysisReport {
    static var mockLowScore: AnalysisReport {
        AnalysisEngine.shared.generate(profile: .mockActiveUser)
    }

    static var mockModerateScore: AnalysisReport {
        AnalysisEngine.shared.generate(profile: .mockModerateUser)
    }

    static var mockElevatedScore: AnalysisReport {
        AnalysisEngine.shared.generate(profile: .mockDeskWorker)
    }
}

extension OnboardingProfileSnapshot {
    /// Desk worker: 8+ sedentary, neck pain, morning+midday stiffness, low exercise
    static var mockDeskWorker: OnboardingProfileSnapshot {
        OnboardingProfileSnapshot(
            goal: UserGoal.reduceStiffness.rawValue,
            focusAreas: [FocusArea.neck.rawValue, FocusArea.upperBack.rawValue],
            painAreas: [PainArea.neck.rawValue, PainArea.upperBack.rawValue, PainArea.lowerBack.rawValue],
            postureIssues: [PostureIssue.forwardHead.rawValue, PostureIssue.roundedShoulders.rawValue],
            stiffnessTimes: [StiffnessTime.morning.rawValue, StiffnessTime.midday.rawValue],
            workType: WorkType.deskOffice.rawValue,
            sedentaryHoursBucket: SedentaryHoursBucket.moreThan8.rawValue,
            exerciseFrequency: ExerciseFrequency.rarely.rawValue,
            motivationLevel: MotivationLevel.ready.rawValue,
            dailyTimeMinutes: 5,
            workStartMinutes: 540,
            workEndMinutes: 1080
        )
    }

    /// Active user: moderate sedentary, rounded shoulders, 3-4 exercise/week
    static var mockActiveUser: OnboardingProfileSnapshot {
        OnboardingProfileSnapshot(
            goal: UserGoal.improvePosture.rawValue,
            focusAreas: [FocusArea.shoulders.rawValue, FocusArea.upperBack.rawValue],
            painAreas: [PainArea.shoulders.rawValue],
            postureIssues: [PostureIssue.roundedShoulders.rawValue],
            stiffnessTimes: [StiffnessTime.evening.rawValue],
            workType: WorkType.hybrid.rawValue,
            sedentaryHoursBucket: SedentaryHoursBucket.fourToSix.rawValue,
            exerciseFrequency: ExerciseFrequency.twoThreeWeek.rawValue,
            motivationLevel: MotivationLevel.veryMotivated.rawValue,
            dailyTimeMinutes: 10,
            workStartMinutes: 540,
            workEndMinutes: 1020
        )
    }

    /// Moderate user: 4-6 sedentary, lower back pain, evening stiffness
    static var mockModerateUser: OnboardingProfileSnapshot {
        OnboardingProfileSnapshot(
            goal: UserGoal.reduceStiffness.rawValue,
            focusAreas: [FocusArea.lowerBack.rawValue, FocusArea.hips.rawValue],
            painAreas: [PainArea.lowerBack.rawValue],
            postureIssues: [PostureIssue.slouching.rawValue],
            stiffnessTimes: [StiffnessTime.evening.rawValue],
            workType: WorkType.deskHome.rawValue,
            sedentaryHoursBucket: SedentaryHoursBucket.fourToSix.rawValue,
            exerciseFrequency: ExerciseFrequency.onceWeek.rawValue,
            motivationLevel: MotivationLevel.curious.rawValue,
            dailyTimeMinutes: 5,
            workStartMinutes: 480,
            workEndMinutes: 1020
        )
    }
}
