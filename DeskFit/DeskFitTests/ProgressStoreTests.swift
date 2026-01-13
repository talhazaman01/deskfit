import XCTest
@testable import DeskFit

/// Tests for ProgressStore - the single source of truth for session progress data.
/// Verifies persistence, session recording, and progress derivation.
@MainActor
final class ProgressStoreTests: XCTestCase {

    var store: ProgressStore!

    override func setUp() {
        super.setUp()
        store = ProgressStore.shared
        // Clear any existing data for clean test state
        store.clearAll()
    }

    override func tearDown() {
        // Clean up test data
        store.clearAll()
        store = nil
        super.tearDown()
    }

    // MARK: - Persistence Tests

    func testPersistenceRoundTrip() {
        // Given: A new entry
        let entry = DailyScoreEntry(
            date: Date(),
            score: 75,
            minutesCompleted: 12,
            sessionsCompleted: 3,
            focusAreas: ["neck", "shoulders"]
        )

        // When: Save and reload
        store.saveEntry(entry)
        store.reload()

        // Then: Entry persists
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.score, 75)
        XCTAssertEqual(store.entries.first?.sessionsCompleted, 3)
    }

    func testMultipleEntriesPersist() {
        // Given: Multiple entries on different days
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        let entries = [
            DailyScoreEntry(date: today, score: 80, minutesCompleted: 15, sessionsCompleted: 4, focusAreas: ["neck"]),
            DailyScoreEntry(date: yesterday, score: 70, minutesCompleted: 10, sessionsCompleted: 2, focusAreas: ["shoulders"]),
            DailyScoreEntry(date: twoDaysAgo, score: 65, minutesCompleted: 8, sessionsCompleted: 2, focusAreas: ["upper_back"])
        ]

        // When: Save all entries and reload
        entries.forEach { store.saveEntry($0) }
        store.reload()

        // Then: All entries persist
        XCTAssertEqual(store.entries.count, 3)
    }

    func testSameDAyEntryIsUpdated() {
        // Given: An entry for today
        let entry1 = DailyScoreEntry(
            date: Date(),
            score: 50,
            minutesCompleted: 5,
            sessionsCompleted: 1,
            focusAreas: ["neck"]
        )
        store.saveEntry(entry1)
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.score, 50)

        // When: Save another entry for the same day
        let entry2 = DailyScoreEntry(
            date: Date(),
            score: 75,
            minutesCompleted: 12,
            sessionsCompleted: 3,
            focusAreas: ["neck", "shoulders"]
        )
        store.saveEntry(entry2)

        // Then: Only one entry exists with updated values
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.score, 75)
        XCTAssertEqual(store.entries.first?.sessionsCompleted, 3)
    }

    // MARK: - hasEnoughData Tests

    func testHasEnoughDataWithNoEntries() {
        // Given: Empty store
        store.clearAll()

        // When: Check summary
        store.updateSummary()

        // Then: hasEnoughData is false
        XCTAssertFalse(store.currentSummary.hasEnoughData)
    }

    func testHasEnoughDataWithOneActiveDay() {
        // Given: One day with activity
        let entry = DailyScoreEntry(
            date: Date(),
            score: 75,
            minutesCompleted: 12,
            sessionsCompleted: 3,
            focusAreas: ["neck"]
        )
        store.saveEntry(entry)

        // Then: hasEnoughData is TRUE (changed from requiring 2 days)
        XCTAssertTrue(store.currentSummary.hasEnoughData)
    }

    func testHasEnoughDataWithMultipleActiveDays() {
        // Given: Multiple days with activity
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        store.saveEntry(DailyScoreEntry(
            date: today, score: 80, minutesCompleted: 15, sessionsCompleted: 4, focusAreas: ["neck"]
        ))
        store.saveEntry(DailyScoreEntry(
            date: yesterday, score: 70, minutesCompleted: 10, sessionsCompleted: 2, focusAreas: ["shoulders"]
        ))

        // Then: hasEnoughData is true
        XCTAssertTrue(store.currentSummary.hasEnoughData)
    }

    func testHasEnoughDataExcludesZeroSessionDays() {
        // Given: Entry with zero sessions (no activity)
        let entry = DailyScoreEntry(
            date: Date(),
            score: 0,
            minutesCompleted: 0,
            sessionsCompleted: 0,
            focusAreas: []
        )
        store.saveEntry(entry)

        // Then: hasEnoughData is false (no actual activity)
        XCTAssertFalse(store.currentSummary.hasEnoughData)
    }

    // MARK: - Weekly Average Tests

    func testWeeklyAverageCalculation() {
        // Given: Entries for 3 days with known scores
        let calendar = Calendar.current
        let today = Date()

        let scores = [80, 70, 60] // Average = 70
        for (index, score) in scores.enumerated() {
            let date = calendar.date(byAdding: .day, value: -index, to: today)!
            store.saveEntry(DailyScoreEntry(
                date: date,
                score: score,
                minutesCompleted: 10,
                sessionsCompleted: 2,
                focusAreas: ["neck"]
            ))
        }

        // Then: Weekly average is correct
        XCTAssertEqual(store.currentSummary.weeklyAverageScore, 70)
    }

    func testWeeklyAverageIgnoresInactiveDays() {
        // Given: Mix of active and inactive days
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        // Active days with scores
        store.saveEntry(DailyScoreEntry(
            date: today, score: 80, minutesCompleted: 10, sessionsCompleted: 2, focusAreas: ["neck"]
        ))
        store.saveEntry(DailyScoreEntry(
            date: twoDaysAgo, score: 60, minutesCompleted: 8, sessionsCompleted: 2, focusAreas: ["neck"]
        ))
        // Inactive day (should not affect average)
        store.saveEntry(DailyScoreEntry(
            date: yesterday, score: 0, minutesCompleted: 0, sessionsCompleted: 0, focusAreas: []
        ))

        // Then: Average only considers active days (80 + 60) / 2 = 70
        XCTAssertEqual(store.currentSummary.weeklyAverageScore, 70)
    }

    // MARK: - Session Recording Tests

    func testRecordSessionCompletionIncrementsSessions() {
        // Given: Empty store
        XCTAssertNil(store.todaysEntry())

        // When: Record a session completion
        store.recordSessionCompletion(
            durationSeconds: 300,
            focusAreas: ["neck", "shoulders"],
            profile: nil,
            currentStreak: 1
        )

        // Then: Today has 1 session
        let entry = store.todaysEntry()
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.sessionsCompleted, 1)
    }

    func testRecordMultipleSessionsAccumulates() {
        // When: Record 3 sessions
        for _ in 0..<3 {
            store.recordSessionCompletion(
                durationSeconds: 240,
                focusAreas: ["neck"],
                profile: nil,
                currentStreak: 1
            )
        }

        // Then: Today has 3 sessions
        let entry = store.todaysEntry()
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.sessionsCompleted, 3)
    }

    func testRecordSessionMergesFocusAreas() {
        // When: Record sessions with different focus areas
        store.recordSessionCompletion(
            durationSeconds: 240,
            focusAreas: ["neck"],
            profile: nil,
            currentStreak: 1
        )
        store.recordSessionCompletion(
            durationSeconds: 240,
            focusAreas: ["shoulders", "upper_back"],
            profile: nil,
            currentStreak: 1
        )

        // Then: Focus areas are merged
        let entry = store.todaysEntry()
        XCTAssertNotNil(entry)
        XCTAssertTrue(entry?.focusAreas.contains("neck") ?? false)
        XCTAssertTrue(entry?.focusAreas.contains("shoulders") ?? false)
        XCTAssertTrue(entry?.focusAreas.contains("upper_back") ?? false)
    }

    // MARK: - Last 7 Days Tests

    func testLast7DaysFilledWithPlaceholders() {
        // Given: Only one active day
        store.saveEntry(DailyScoreEntry(
            date: Date(),
            score: 75,
            minutesCompleted: 10,
            sessionsCompleted: 2,
            focusAreas: ["neck"]
        ))

        // Then: Last 7 days array has 7 elements
        XCTAssertEqual(store.currentSummary.last7Days.count, 7)

        // And: Only 1 day has activity
        let activeDays = store.currentSummary.last7Days.filter { $0.hasActivity }
        XCTAssertEqual(activeDays.count, 1)
    }

    func testLast7DaysOrderedCorrectly() {
        // Given: Entries for multiple days
        let calendar = Calendar.current
        let today = Date()

        for dayOffset in [0, 2, 4] {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            store.saveEntry(DailyScoreEntry(
                date: date,
                score: 70 + dayOffset * 5,
                minutesCompleted: 10,
                sessionsCompleted: 2,
                focusAreas: ["neck"]
            ))
        }

        // Then: Days are in chronological order (oldest first)
        let days = store.currentSummary.last7Days
        XCTAssertEqual(days.count, 7)

        // First element should be 6 days ago, last should be today
        let firstDate = Calendar.current.startOfDay(for: days.first!.date)
        let expectedFirstDate = Calendar.current.startOfDay(
            for: calendar.date(byAdding: .day, value: -6, to: today)!
        )
        XCTAssertEqual(firstDate, expectedFirstDate)

        let lastDate = Calendar.current.startOfDay(for: days.last!.date)
        let expectedLastDate = Calendar.current.startOfDay(for: today)
        XCTAssertEqual(lastDate, expectedLastDate)
    }
}
