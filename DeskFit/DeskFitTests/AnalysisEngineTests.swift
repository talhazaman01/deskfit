//
//  AnalysisEngineTests.swift
//  DeskFitTests
//
//  Tests for AnalysisEngine scoring and insight generation.
//

import Testing
@testable import DeskFit

struct AnalysisEngineTests {

    // MARK: - Test Personas

    /// Persona 1: Desk worker with high sedentary hours and multiple issues
    /// - 8+ sedentary hours
    /// - Neck pain, upper back pain
    /// - Forward head, rounded shoulders posture issues
    /// - Morning + midday stiffness
    /// - Rarely exercises
    /// - 5 min daily time
    static let deskWorkerProfile = OnboardingProfileSnapshot(
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

    /// Persona 2: Active user with moderate concerns
    /// - 4-6 sedentary hours
    /// - Shoulder pain
    /// - Rounded shoulders
    /// - Evening stiffness only
    /// - 2-3x per week exercise
    /// - 10 min daily time
    static let activeUserProfile = OnboardingProfileSnapshot(
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

    /// Persona 3: Low time user with moderate issues
    /// - 4-6 sedentary hours
    /// - Lower back pain
    /// - Slouching posture
    /// - Evening stiffness
    /// - Once a week exercise
    /// - 5 min daily time
    static let lowTimeUserProfile = OnboardingProfileSnapshot(
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

    // MARK: - Score Tests

    @Test("Desk worker should have elevated score")
    func deskWorkerScoreIsElevated() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        #expect(report.score.category == .elevated)
        #expect(report.score.value >= 67)
    }

    @Test("Active user should have low to moderate score")
    func activeUserScoreIsLowToModerate() {
        let report = AnalysisEngine.shared.generate(profile: Self.activeUserProfile)

        #expect(report.score.category == .low || report.score.category == .moderate)
        #expect(report.score.value <= 66)
    }

    @Test("Low time user should have moderate score")
    func lowTimeUserScoreIsModerate() {
        let report = AnalysisEngine.shared.generate(profile: Self.lowTimeUserProfile)

        #expect(report.score.category == .moderate || report.score.category == .low)
        #expect(report.score.value >= 20 && report.score.value <= 66)
    }

    // MARK: - Insight Count Tests

    @Test("All personas generate at least 3 insights")
    func allPersonasGenerateMinimumInsights() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)
        let activeReport = AnalysisEngine.shared.generate(profile: Self.activeUserProfile)
        let lowTimeReport = AnalysisEngine.shared.generate(profile: Self.lowTimeUserProfile)

        #expect(deskReport.insights.count >= 3)
        #expect(activeReport.insights.count >= 3)
        #expect(lowTimeReport.insights.count >= 3)
    }

    @Test("No more than 6 insights generated")
    func insightsAreCappedAtSix() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)
        let activeReport = AnalysisEngine.shared.generate(profile: Self.activeUserProfile)
        let lowTimeReport = AnalysisEngine.shared.generate(profile: Self.lowTimeUserProfile)

        #expect(deskReport.insights.count <= 6)
        #expect(activeReport.insights.count <= 6)
        #expect(lowTimeReport.insights.count <= 6)
    }

    // MARK: - Specific Insight Trigger Tests

    @Test("Desk worker generates sedentary load insight")
    func deskWorkerHasSedentaryLoadInsight() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        let hasSedentaryInsight = report.insights.contains { $0.title == "Sedentary Load" }
        #expect(hasSedentaryInsight)
    }

    @Test("Desk worker generates stiffness pattern insight")
    func deskWorkerHasStiffnessPatternInsight() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        let hasStiffnessInsight = report.insights.contains { $0.title == "Stiffness Pattern" }
        #expect(hasStiffnessInsight)
    }

    @Test("Desk worker generates neck upper back insight")
    func deskWorkerHasNeckUpperBackInsight() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        let hasNeckInsight = report.insights.contains { $0.title == "Neck & Upper Back Focus" }
        #expect(hasNeckInsight)
    }

    @Test("Desk worker generates movement baseline insight for rarely exercising")
    func deskWorkerHasMovementBaselineInsight() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        let hasMovementInsight = report.insights.contains { $0.title == "Movement Baseline" }
        #expect(hasMovementInsight)
    }

    @Test("Active user generates work context insight")
    func activeUserHasWorkContextInsight() {
        let report = AnalysisEngine.shared.generate(profile: Self.activeUserProfile)

        let hasWorkInsight = report.insights.contains { $0.title == "Work Environment" }
        #expect(hasWorkInsight)
    }

    @Test("Low time user generates time efficiency insight")
    func lowTimeUserHasTimeEfficiencyInsight() {
        let report = AnalysisEngine.shared.generate(profile: Self.lowTimeUserProfile)

        let hasTimeInsight = report.insights.contains { $0.title == "Time-Efficient Approach" }
        #expect(hasTimeInsight)
    }

    @Test("Low time user generates lower back insight")
    func lowTimeUserHasLowerBackInsight() {
        let report = AnalysisEngine.shared.generate(profile: Self.lowTimeUserProfile)

        let hasLowerBackInsight = report.insights.contains { $0.title == "Lower Back & Hips" }
        #expect(hasLowerBackInsight)
    }

    // MARK: - Determinism Tests

    @Test("Same input produces same output (deterministic)")
    func outputIsDeterministic() {
        let report1 = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)
        let report2 = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        // Score should be identical
        #expect(report1.score.value == report2.score.value)
        #expect(report1.score.category == report2.score.category)

        // Insight count and titles should be identical
        #expect(report1.insights.count == report2.insights.count)
        let titles1 = report1.insights.map { $0.title }.sorted()
        let titles2 = report2.insights.map { $0.title }.sorted()
        #expect(titles1 == titles2)

        // Risk factors count should be identical
        #expect(report1.riskFactors.count == report2.riskFactors.count)

        // Summary should be identical
        #expect(report1.summaryHeadline == report2.summaryHeadline)
        #expect(report1.summaryBody == report2.summaryBody)
    }

    @Test("Different inputs produce different scores")
    func differentInputsProduceDifferentScores() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)
        let activeReport = AnalysisEngine.shared.generate(profile: Self.activeUserProfile)

        #expect(deskReport.score.value != activeReport.score.value)
    }

    // MARK: - Risk Factors Tests

    @Test("Risk factors are generated based on profile")
    func riskFactorsAreGenerated() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)
        let activeReport = AnalysisEngine.shared.generate(profile: Self.activeUserProfile)
        let lowTimeReport = AnalysisEngine.shared.generate(profile: Self.lowTimeUserProfile)

        #expect(!deskReport.riskFactors.isEmpty)
        #expect(!activeReport.riskFactors.isEmpty)
        #expect(!lowTimeReport.riskFactors.isEmpty)
    }

    @Test("Desk worker has more risk factors than active user")
    func deskWorkerHasMoreRiskFactors() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)
        let activeReport = AnalysisEngine.shared.generate(profile: Self.activeUserProfile)

        #expect(deskReport.riskFactors.count >= activeReport.riskFactors.count)
    }

    @Test("Risk factors limited to 8 max")
    func riskFactorsAreCapped() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        #expect(deskReport.riskFactors.count <= 8)
    }

    // MARK: - Focus Areas Tests

    @Test("Focus areas are derived from profile")
    func focusAreasAreDerived() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        #expect(!deskReport.focusAreas.isEmpty)
        #expect(deskReport.focusAreas.contains("Neck") || deskReport.focusAreas.contains("Upper Back"))
    }

    // MARK: - Weekly Actions Tests

    @Test("Weekly actions are generated")
    func weeklyActionsAreGenerated() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        #expect(!deskReport.weeklyActions.isEmpty)
        #expect(deskReport.weeklyActions.count >= 2)
    }

    // MARK: - Summary Tests

    @Test("Summary is non-empty")
    func summaryIsNonEmpty() {
        let deskReport = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        #expect(!deskReport.summaryHeadline.isEmpty)
        #expect(!deskReport.summaryBody.isEmpty)
    }

    @Test("Elevated score has appropriate summary")
    func elevatedScoreHasAppropriateHeadline() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        #expect(report.score.category == .elevated)
        #expect(report.summaryHeadline.contains("improvement"))
    }

    // MARK: - Disclaimers Tests

    @Test("Default disclaimers are included")
    func defaultDisclaimersAreIncluded() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        #expect(!report.disclaimers.isEmpty)
        #expect(report.disclaimers.count >= 3)
    }

    // MARK: - Score Category Tests

    @Test("Score category boundaries are correct")
    func scoreCategoryBoundaries() {
        #expect(ScoreCategory.from(score: 0) == .low)
        #expect(ScoreCategory.from(score: 33) == .low)
        #expect(ScoreCategory.from(score: 34) == .moderate)
        #expect(ScoreCategory.from(score: 66) == .moderate)
        #expect(ScoreCategory.from(score: 67) == .elevated)
        #expect(ScoreCategory.from(score: 100) == .elevated)
    }

    @Test("Analysis score clamps to 0-100")
    func analysisScoreClampsToRange() {
        let lowScore = AnalysisScore(value: -10)
        let highScore = AnalysisScore(value: 150)

        #expect(lowScore.value == 0)
        #expect(highScore.value == 100)
    }

    // MARK: - Edge Case Tests

    @Test("Empty pain areas still generates report")
    func emptyPainAreasGeneratesReport() {
        let profile = OnboardingProfileSnapshot(
            goal: UserGoal.moveMore.rawValue,
            focusAreas: [FocusArea.neck.rawValue],
            painAreas: [],
            postureIssues: [],
            stiffnessTimes: [StiffnessTime.morning.rawValue],
            workType: nil,
            sedentaryHoursBucket: SedentaryHoursBucket.twoToFour.rawValue,
            exerciseFrequency: ExerciseFrequency.twoThreeWeek.rawValue,
            motivationLevel: nil,
            dailyTimeMinutes: 5,
            workStartMinutes: 540,
            workEndMinutes: 1020
        )

        let report = AnalysisEngine.shared.generate(profile: profile)

        #expect(report.score.value >= 0)
        #expect(!report.summaryHeadline.isEmpty)
    }

    @Test("Missing optional fields handled gracefully")
    func missingOptionalFieldsHandled() {
        let profile = OnboardingProfileSnapshot(
            goal: UserGoal.buildHabit.rawValue,
            focusAreas: [],
            painAreas: [],
            postureIssues: [],
            stiffnessTimes: [],
            workType: nil,
            sedentaryHoursBucket: nil,
            exerciseFrequency: nil,
            motivationLevel: nil,
            dailyTimeMinutes: 5,
            workStartMinutes: 540,
            workEndMinutes: 1020
        )

        let report = AnalysisEngine.shared.generate(profile: profile)

        #expect(report.score.value >= 0)
        #expect(report.score.value <= 100)
        #expect(!report.summaryHeadline.isEmpty)
    }

    // MARK: - Insight Severity Tests

    @Test("High severity insights sorted first")
    func highSeverityInsightsSortedFirst() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        guard report.insights.count >= 2 else { return }

        // First insight should have severity <= later insights (high=0, medium=1, low=2)
        let firstSeverityOrder = report.insights[0].severity.sortOrder
        let secondSeverityOrder = report.insights[1].severity.sortOrder

        #expect(firstSeverityOrder <= secondSeverityOrder)
    }

    // MARK: - Insight Tags Tests

    @Test("Insights have tags for analytics")
    func insightsHaveTags() {
        let report = AnalysisEngine.shared.generate(profile: Self.deskWorkerProfile)

        for insight in report.insights {
            #expect(!insight.tags.isEmpty)
        }
    }
}
