//
//  ScoreEngineTests.swift
//  DeskFitTests
//
//  Tests for ScoreEngine deterministic scoring and bounds.
//

import Foundation
import Testing
@testable import DeskFit

struct ScoreEngineTests {

    // MARK: - Base Score Tests

    @Test("Base score with no activity starts at expected value")
    func baseScoreWithNoActivity() {
        let score = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 0,
            minutesCompleted: 0,
            streakDays: 0
        )

        // Base score is 60, but with no activity and high sedentary it can be lower
        #expect(score >= ScoreEngine.minimumScore)
        #expect(score <= ScoreEngine.maximumScore)
        #expect(score == ScoreEngine.baseScore) // No modifiers, should be exactly base
    }

    @Test("Score increases with sessions completed")
    func scoreIncreasesWithSessions() {
        let baseScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 0,
            minutesCompleted: 0,
            streakDays: 0
        )

        let oneSessionScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 0
        )

        let twoSessionScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 2,
            minutesCompleted: 10,
            streakDays: 0
        )

        #expect(oneSessionScore > baseScore)
        #expect(twoSessionScore > oneSessionScore)
    }

    @Test("Session points are capped")
    func sessionPointsAreCapped() {
        let threeSessionScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 3,
            minutesCompleted: 15,
            streakDays: 0
        )

        let tenSessionScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 10,
            minutesCompleted: 50,
            streakDays: 0
        )

        // Both should be capped at max session points
        // 3 sessions = 24 points (under cap of 25)
        // 10 sessions would be 80 points but capped at 25
        let expectedCapDifference = ScoreEngine.maxSessionPoints - (3 * ScoreEngine.pointsPerSession)
        #expect(tenSessionScore - threeSessionScore <= expectedCapDifference)
    }

    // MARK: - Streak Bonus Tests

    @Test("Streak increases score")
    func streakIncreasesScore() {
        let noStreakScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 0
        )

        let threeStreakScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 3
        )

        let sevenStreakScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 7
        )

        #expect(threeStreakScore > noStreakScore)
        #expect(sevenStreakScore > threeStreakScore)
    }

    @Test("Streak bonus is capped")
    func streakBonusIsCapped() {
        let fiveStreakScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 5
        )

        let hundredStreakScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 100
        )

        // Both should eventually hit the streak cap
        let maxPossibleDiff = ScoreEngine.maxStreakBonus - (5 * ScoreEngine.pointsPerStreakDay)
        #expect(hundredStreakScore - fiveStreakScore <= maxPossibleDiff)
    }

    // MARK: - Stiffness Time Match Tests

    @Test("Stiffness time match gives bonus")
    func stiffnessTimeMatchGivesBonus() {
        let noMatchScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 0,
            stiffnessTimesMatched: 0
        )

        let oneMatchScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 0,
            stiffnessTimesMatched: 1
        )

        #expect(oneMatchScore > noMatchScore)
        #expect(oneMatchScore - noMatchScore == ScoreEngine.stiffnessTimeMatchBonus)
    }

    // MARK: - Sedentary Penalty Tests

    @Test("High sedentary with no sessions gives penalty")
    func highSedentaryPenalty() {
        let noSedentaryScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 0,
            minutesCompleted: 0,
            streakDays: 0,
            sedentaryBucket: .lessThan2
        )

        let highSedentaryScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 0,
            minutesCompleted: 0,
            streakDays: 0,
            sedentaryBucket: .moreThan8
        )

        #expect(highSedentaryScore < noSedentaryScore)
    }

    @Test("Sedentary penalty only applies when no sessions")
    func sedentaryPenaltyOnlyWithNoSessions() {
        let withSessionsHighSedentary = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 0,
            sedentaryBucket: .moreThan8
        )

        let withSessionsLowSedentary = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 0,
            sedentaryBucket: .lessThan2
        )

        // With sessions completed, sedentary penalty should NOT apply
        #expect(withSessionsHighSedentary == withSessionsLowSedentary)
    }

    // MARK: - Bounds Tests

    @Test("Score never goes below minimum")
    func scoreNeverBelowMinimum() {
        // Worst case: no sessions, high sedentary
        let worstCaseScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 0,
            minutesCompleted: 0,
            streakDays: 0,
            stiffnessTimesMatched: 0,
            sedentaryBucket: .moreThan8
        )

        #expect(worstCaseScore >= ScoreEngine.minimumScore)
    }

    @Test("Score never exceeds maximum")
    func scoreNeverExceedsMaximum() {
        // Best case: max sessions, max streak, stiffness matches, many focus areas
        let bestCaseScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 10,
            minutesCompleted: 50,
            streakDays: 100,
            stiffnessTimesMatched: 5,
            sedentaryBucket: .lessThan2,
            focusAreas: ["neck", "shoulders", "upper_back", "lower_back"]
        )

        #expect(bestCaseScore <= ScoreEngine.maximumScore)
    }

    // MARK: - Determinism Tests

    @Test("Same inputs produce same output (deterministic)")
    func outputIsDeterministic() {
        let score1 = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 2,
            minutesCompleted: 10,
            streakDays: 5,
            stiffnessTimesMatched: 1,
            sedentaryBucket: .fourToSix,
            focusAreas: ["neck", "shoulders"]
        )

        let score2 = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 2,
            minutesCompleted: 10,
            streakDays: 5,
            stiffnessTimesMatched: 1,
            sedentaryBucket: .fourToSix,
            focusAreas: ["neck", "shoulders"]
        )

        #expect(score1 == score2)
    }

    @Test("Different inputs produce different scores")
    func differentInputsProduceDifferentScores() {
        let activeScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 3,
            minutesCompleted: 15,
            streakDays: 7
        )

        let inactiveScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 0,
            minutesCompleted: 0,
            streakDays: 0
        )

        #expect(activeScore != inactiveScore)
        #expect(activeScore > inactiveScore)
    }

    // MARK: - Focus Area Bonus Tests

    @Test("Multiple focus areas give small bonus")
    func multipleFocusAreasGiveBonus() {
        let oneFocusScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 0,
            focusAreas: ["neck"]
        )

        let threeFocusScore = ScoreEngine.shared.calculateScore(
            sessionsCompleted: 1,
            minutesCompleted: 5,
            streakDays: 0,
            focusAreas: ["neck", "shoulders", "upper_back"]
        )

        #expect(threeFocusScore > oneFocusScore)
    }

    // MARK: - Daily Score Entry Tests

    @Test("Calculate daily score creates valid entry")
    func calculateDailyScoreCreatesValidEntry() {
        let profile = OnboardingProfileSnapshot(
            goal: UserGoal.reduceStiffness.rawValue,
            focusAreas: [FocusArea.neck.rawValue, FocusArea.shoulders.rawValue],
            painAreas: [],
            postureIssues: [],
            stiffnessTimes: [StiffnessTime.morning.rawValue, StiffnessTime.midday.rawValue],
            workType: nil,
            sedentaryHoursBucket: SedentaryHoursBucket.fourToSix.rawValue,
            exerciseFrequency: nil,
            motivationLevel: nil,
            dailyTimeMinutes: 10,
            workStartMinutes: 540,
            workEndMinutes: 1020
        )

        let entry = ScoreEngine.shared.calculateDailyScore(
            for: Date(),
            sessionsCompleted: 2,
            minutesCompleted: 8,
            focusAreas: ["neck", "shoulders"],
            stiffnessTimesTriggered: ["morning"],
            profile: profile,
            currentStreak: 3
        )

        #expect(entry.score >= ScoreEngine.minimumScore)
        #expect(entry.score <= ScoreEngine.maximumScore)
        #expect(entry.sessionsCompleted == 2)
        #expect(entry.minutesCompleted == 8)
        #expect(entry.focusAreas == ["neck", "shoulders"])
    }

    // MARK: - Score Projection Tests

    @Test("Projected score after session is higher")
    func projectedScoreAfterSessionIsHigher() {
        let currentScore = 65
        let currentSessions = 1
        let streakDays = 3

        let projectedScore = ScoreEngine.shared.projectedScoreAfterSession(
            currentScore: currentScore,
            currentSessions: currentSessions,
            streakDays: streakDays
        )

        #expect(projectedScore >= currentScore)
    }

    @Test("Projection doesn't exceed maximum")
    func projectionDoesntExceedMaximum() {
        let projectedScore = ScoreEngine.shared.projectedScoreAfterSession(
            currentScore: 98,
            currentSessions: 5,
            streakDays: 10
        )

        #expect(projectedScore <= ScoreEngine.maximumScore)
    }

    // MARK: - Weekly Average Tests

    @Test("Weekly average calculated correctly")
    func weeklyAverageCalculatedCorrectly() {
        let entries = [
            DailyScoreEntry(
                date: Date(),
                score: 70,
                minutesCompleted: 10,
                sessionsCompleted: 2,
                focusAreas: ["neck"]
            ),
            DailyScoreEntry(
                date: Date().addingTimeInterval(-86400),
                score: 80,
                minutesCompleted: 15,
                sessionsCompleted: 3,
                focusAreas: ["neck"]
            ),
            DailyScoreEntry(
                date: Date().addingTimeInterval(-86400 * 2),
                score: 0, // No activity
                minutesCompleted: 0,
                sessionsCompleted: 0,
                focusAreas: []
            )
        ]

        let average = ScoreEngine.shared.calculateWeeklyAverage(from: entries)

        // Should only average active days (70 + 80) / 2 = 75
        #expect(average == 75)
    }

    @Test("Weekly average with no active days returns zero")
    func weeklyAverageWithNoActiveDaysReturnsZero() {
        let entries = [
            DailyScoreEntry(
                date: Date(),
                score: 0,
                minutesCompleted: 0,
                sessionsCompleted: 0,
                focusAreas: []
            )
        ]

        let average = ScoreEngine.shared.calculateWeeklyAverage(from: entries)

        #expect(average == 0)
    }

    // MARK: - Session Time Category Tests

    @Test("Session time category determined by hour")
    func sessionTimeCategoryDeterminedByHour() {
        let calendar = Calendar.current

        // Create date at 9 AM
        var morningComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        morningComponents.hour = 9
        let morningDate = calendar.date(from: morningComponents)!

        // Create date at 2 PM
        var middayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        middayComponents.hour = 14
        let middayDate = calendar.date(from: middayComponents)!

        // Create date at 7 PM
        var eveningComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        eveningComponents.hour = 19
        let eveningDate = calendar.date(from: eveningComponents)!

        let morningCategory = ScoreEngine.shared.sessionTimeCategory(for: morningDate)
        let middayCategory = ScoreEngine.shared.sessionTimeCategory(for: middayDate)
        let eveningCategory = ScoreEngine.shared.sessionTimeCategory(for: eveningDate)

        #expect(morningCategory == .morning)
        #expect(middayCategory == .midday)
        #expect(eveningCategory == .evening)
    }

    // MARK: - Score Explanation Tests

    @Test("Score explanation includes components")
    func scoreExplanationIncludesComponents() {
        let explanation = ScoreEngine.shared.explainScore(
            score: 85,
            sessionsCompleted: 2,
            streakDays: 3,
            stiffnessTimesMatched: 1
        )

        #expect(explanation.contains("Base"))
        #expect(explanation.contains("Sessions"))
        #expect(explanation.contains("Streak"))
        #expect(explanation.contains("Timing"))
    }

    // MARK: - Total Sessions Tests

    @Test("Total sessions calculated correctly")
    func totalSessionsCalculatedCorrectly() {
        let entries = [
            DailyScoreEntry(date: Date(), score: 70, minutesCompleted: 10, sessionsCompleted: 2, focusAreas: []),
            DailyScoreEntry(date: Date().addingTimeInterval(-86400), score: 80, minutesCompleted: 15, sessionsCompleted: 3, focusAreas: []),
            DailyScoreEntry(date: Date().addingTimeInterval(-86400 * 2), score: 60, minutesCompleted: 5, sessionsCompleted: 1, focusAreas: [])
        ]

        let total = ScoreEngine.shared.calculateTotalSessions(from: entries)

        #expect(total == 6)
    }

    // MARK: - Total Minutes Tests

    @Test("Total minutes calculated correctly")
    func totalMinutesCalculatedCorrectly() {
        let entries = [
            DailyScoreEntry(date: Date(), score: 70, minutesCompleted: 10, sessionsCompleted: 2, focusAreas: []),
            DailyScoreEntry(date: Date().addingTimeInterval(-86400), score: 80, minutesCompleted: 15, sessionsCompleted: 3, focusAreas: [])
        ]

        let total = ScoreEngine.shared.calculateTotalMinutes(from: entries)

        #expect(total == 25)
    }
}
