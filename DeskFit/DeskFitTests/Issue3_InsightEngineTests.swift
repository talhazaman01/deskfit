import XCTest
@testable import DeskFit

/// Tests for Issue 3 - InsightEngine determinism and personalization
/// Verifies that insights are deterministic and vary by persona.
@MainActor
final class InsightEngineTests: XCTestCase {

    // MARK: - Persona Definitions

    /// Desk worker: high sedentary, neck pain, morning stiffness
    private var deskWorkerPersona: OnboardingProfileSnapshot {
        OnboardingProfileSnapshot(
            goal: UserGoal.reduceStiffness.rawValue,
            focusAreas: [FocusArea.neck.rawValue, FocusArea.upperBack.rawValue],
            painAreas: [PainArea.neck.rawValue, PainArea.upperBack.rawValue],
            postureIssues: [PostureIssue.forwardHead.rawValue],
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

    /// Active user: moderate sedentary, shoulder focus, evening stiffness
    private var activePersona: OnboardingProfileSnapshot {
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

    /// Lower back focus: hip pain, lower back issues, all day stiffness
    private var lowerBackPersona: OnboardingProfileSnapshot {
        OnboardingProfileSnapshot(
            goal: UserGoal.reduceStiffness.rawValue,
            focusAreas: [FocusArea.lowerBack.rawValue, FocusArea.hips.rawValue],
            painAreas: [PainArea.lowerBack.rawValue, PainArea.hips.rawValue],
            postureIssues: [PostureIssue.slouching.rawValue, PostureIssue.anteriorPelvicTilt.rawValue],
            stiffnessTimes: [StiffnessTime.morning.rawValue, StiffnessTime.midday.rawValue, StiffnessTime.evening.rawValue],
            workType: WorkType.deskHome.rawValue,
            sedentaryHoursBucket: SedentaryHoursBucket.sixToEight.rawValue,
            exerciseFrequency: ExerciseFrequency.onceWeek.rawValue,
            motivationLevel: MotivationLevel.curious.rawValue,
            dailyTimeMinutes: 5,
            workStartMinutes: 480,
            workEndMinutes: 1020
        )
    }

    // MARK: - Determinism Tests

    func testSamePersonaSameDateProducesSameInsights() async {
        // Given: Same persona
        let persona = deskWorkerPersona
        let progressSummary = createSampleProgressSummary()

        // When: Generate insights twice with same inputs
        let insights1 = InsightEngine.shared.getTodaysInsights(
            profile: persona,
            progressSummary: progressSummary,
            todaysPlan: nil
        )

        // Clear cache and regenerate
        _ = InsightEngine.shared.regenerateInsights(
            profile: persona,
            progressSummary: progressSummary,
            todaysPlan: nil
        )

        let insights2 = InsightEngine.shared.getTodaysInsights(
            profile: persona,
            progressSummary: progressSummary,
            todaysPlan: nil
        )

        // Then: Same insights are produced
        XCTAssertEqual(insights1.count, insights2.count)

        for (insight1, insight2) in zip(insights1, insights2) {
            XCTAssertEqual(insight1.title, insight2.title)
            XCTAssertEqual(insight1.category, insight2.category)
        }
    }

    // MARK: - Different Personas Produce Different Insights

    func testDifferentPersonasProduceDifferentInsights() async {
        // Given: Three different personas
        let progressSummary = createSampleProgressSummary()

        // When: Generate insights for each
        let deskWorkerInsights = InsightEngine.shared.regenerateInsights(
            profile: deskWorkerPersona,
            progressSummary: progressSummary,
            todaysPlan: nil
        )

        let activeInsights = InsightEngine.shared.regenerateInsights(
            profile: activePersona,
            progressSummary: progressSummary,
            todaysPlan: nil
        )

        let lowerBackInsights = InsightEngine.shared.regenerateInsights(
            profile: lowerBackPersona,
            progressSummary: progressSummary,
            todaysPlan: nil
        )

        // Then: Insights differ between personas
        XCTAssertFalse(insightsAreIdentical(deskWorkerInsights, activeInsights))
        XCTAssertFalse(insightsAreIdentical(deskWorkerInsights, lowerBackInsights))
        XCTAssertFalse(insightsAreIdentical(activeInsights, lowerBackInsights))
    }

    func testDeskWorkerGetsPainSpecificInsight() async {
        // Given: Desk worker with neck pain
        let insights = InsightEngine.shared.regenerateInsights(
            profile: deskWorkerPersona,
            progressSummary: createSampleProgressSummary(),
            todaysPlan: nil
        )

        // Then: At least one insight references pain areas
        let hasPainInsight = insights.contains { insight in
            insight.category == .painSpecific ||
            insight.debugTags.contains(where: { $0.contains("pain") })
        }
        XCTAssertTrue(hasPainInsight, "Desk worker should get pain-specific insight")
    }

    func testHighSedentaryGetsSedentaryRiskInsight() async {
        // Given: Persona with high sedentary hours
        let insights = InsightEngine.shared.regenerateInsights(
            profile: deskWorkerPersona, // Has 8+ hours sedentary
            progressSummary: createSampleProgressSummary(),
            todaysPlan: nil
        )

        // Then: Contains sedentary-related content
        let hasSedentaryContent = insights.contains { insight in
            insight.category == .sedentaryRisk ||
            insight.body.lowercased().contains("sitting") ||
            insight.body.lowercased().contains("sedentary")
        }
        XCTAssertTrue(hasSedentaryContent, "High sedentary user should get sedentary-related insight")
    }

    // MARK: - Insight Content Safety Tests

    func testInsightsDoNotContainMedicalClaims() async {
        // Given: Various personas
        let personas = [deskWorkerPersona, activePersona, lowerBackPersona]

        for persona in personas {
            let insights = InsightEngine.shared.regenerateInsights(
                profile: persona,
                progressSummary: createSampleProgressSummary(),
                todaysPlan: nil
            )

            for insight in insights {
                // Then: No medical claims
                XCTAssertFalse(insight.body.contains("will cure"), "Should not claim to cure")
                XCTAssertFalse(insight.body.contains("guaranteed"), "Should not guarantee outcomes")
                XCTAssertFalse(insight.body.contains("diagnos"), "Should not diagnose")

                // Safe language is used
                let usesSafeLanguage =
                    insight.body.contains("may") ||
                    insight.body.contains("can help") ||
                    insight.body.contains("often") ||
                    insight.body.contains("typically") ||
                    insight.body.contains("commonly")

                XCTAssertTrue(usesSafeLanguage, "Should use safe language like 'may', 'can help', 'often'")
            }
        }
    }

    // MARK: - Insight Count Tests

    func testGeneratesOneToThreeInsights() async {
        // Given: Various personas
        let personas = [deskWorkerPersona, activePersona, lowerBackPersona]

        for persona in personas {
            let insights = InsightEngine.shared.regenerateInsights(
                profile: persona,
                progressSummary: createSampleProgressSummary(),
                todaysPlan: nil
            )

            // Then: 1-3 insights are generated
            XCTAssertGreaterThanOrEqual(insights.count, 1, "Should generate at least 1 insight")
            XCTAssertLessThanOrEqual(insights.count, 3, "Should generate at most 3 insights")
        }
    }

    // MARK: - AnalysisEngine Tests (Onboarding Assessment)

    func testAnalysisEngineProducesDeterministicResults() {
        // Given: Same profile
        let profile = deskWorkerPersona

        // When: Generate report twice
        let report1 = AnalysisEngine.shared.generate(profile: profile)
        let report2 = AnalysisEngine.shared.generate(profile: profile)

        // Then: Same results
        XCTAssertEqual(report1.score.value, report2.score.value)
        XCTAssertEqual(report1.insights.count, report2.insights.count)
        XCTAssertEqual(report1.focusAreas.sorted(), report2.focusAreas.sorted())
    }

    func testAnalysisEngineScoreVariesByProfile() {
        // Given: Different profiles
        let deskWorkerReport = AnalysisEngine.shared.generate(profile: deskWorkerPersona)
        let activeReport = AnalysisEngine.shared.generate(profile: activePersona)

        // Then: Scores differ (desk worker should be higher risk)
        XCTAssertNotEqual(deskWorkerReport.score.value, activeReport.score.value)
        XCTAssertGreaterThan(deskWorkerReport.score.value, activeReport.score.value,
                            "Desk worker with more risk factors should have higher score")
    }

    func testAnalysisEngineGeneratesPersonalizedInsights() {
        // Given: Profile with neck pain
        let report = AnalysisEngine.shared.generate(profile: deskWorkerPersona)

        // Then: Insights reference the user's specific concerns
        let insightTexts = report.insights.map { $0.body.lowercased() }
        let mentionsNeck = insightTexts.contains { $0.contains("neck") }

        XCTAssertTrue(mentionsNeck, "Insights should reference user's neck pain")
    }

    func testAnalysisEngineDisclaimersArePresent() {
        // Given: Any profile
        let report = AnalysisEngine.shared.generate(profile: deskWorkerPersona)

        // Then: Disclaimers are included
        XCTAssertFalse(report.disclaimers.isEmpty, "Report should include disclaimers")
        XCTAssertGreaterThanOrEqual(report.disclaimers.count, 2, "Should have multiple disclaimers")
    }

    // MARK: - Helpers

    private func createSampleProgressSummary() -> ProgressSummary {
        ProgressSummary(
            weekStartDate: Date(),
            weeklyAverageScore: 72,
            weeklySessionsCompleted: 8,
            weeklyMinutesCompleted: 45,
            streakDays: 3,
            last7Days: [],
            wins: []
        )
    }

    private func insightsAreIdentical(_ a: [DailyInsight], _ b: [DailyInsight]) -> Bool {
        guard a.count == b.count else { return false }

        for (insightA, insightB) in zip(a, b) {
            if insightA.title != insightB.title ||
               insightA.body != insightB.body ||
               insightA.category != insightB.category {
                return false
            }
        }
        return true
    }
}
