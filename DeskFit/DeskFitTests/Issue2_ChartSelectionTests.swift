import XCTest
@testable import DeskFit

/// Tests for Issue 2 - Interactive weekly chart
/// Verifies selection logic, toggle behavior, and delta calculations.
@MainActor
final class ChartSelectionTests: XCTestCase {

    var viewModel: WeeklyChartViewModel!

    override func setUp() {
        super.setUp()
        viewModel = WeeklyChartViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Selection Toggle Tests

    func testInitialSelectionIsNil() {
        // Then: No day is selected initially
        XCTAssertNil(viewModel.selectedDayIndex)
    }

    func testToggleSelectionSelectsDay() {
        // When: Toggle selection for day 2
        viewModel.toggleSelection(for: 2)

        // Then: Day 2 is selected
        XCTAssertEqual(viewModel.selectedDayIndex, 2)
    }

    func testToggleSelectionDeselectsSameDay() {
        // Given: Day 3 is selected
        viewModel.toggleSelection(for: 3)
        XCTAssertEqual(viewModel.selectedDayIndex, 3)

        // When: Toggle the same day again
        viewModel.toggleSelection(for: 3)

        // Then: Selection is cleared
        XCTAssertNil(viewModel.selectedDayIndex)
    }

    func testToggleSelectionSwitchesToDifferentDay() {
        // Given: Day 1 is selected
        viewModel.toggleSelection(for: 1)
        XCTAssertEqual(viewModel.selectedDayIndex, 1)

        // When: Select a different day
        viewModel.toggleSelection(for: 4)

        // Then: New day is selected
        XCTAssertEqual(viewModel.selectedDayIndex, 4)
    }

    func testClearSelectionResetsToNil() {
        // Given: A day is selected
        viewModel.toggleSelection(for: 5)
        XCTAssertNotNil(viewModel.selectedDayIndex)

        // When: Clear selection
        viewModel.clearSelection()

        // Then: Selection is nil
        XCTAssertNil(viewModel.selectedDayIndex)
    }

    // MARK: - Entry Update Tests

    func testUpdateEntriesStoresEntries() {
        // Given: Sample entries
        let entries = DailyScoreEntry.sampleWeek

        // When: Update entries
        viewModel.updateEntries(entries)

        // Then: Entries are stored
        XCTAssertEqual(viewModel.entries.count, entries.count)
    }

    func testUpdateEntriesClearsOutOfBoundsSelection() {
        // Given: 7 entries and selection at index 6
        let entries = DailyScoreEntry.sampleWeek
        viewModel.updateEntries(entries)
        viewModel.toggleSelection(for: 6)
        XCTAssertEqual(viewModel.selectedDayIndex, 6)

        // When: Update with fewer entries
        let fewerEntries = Array(entries.prefix(3))
        viewModel.updateEntries(fewerEntries)

        // Then: Selection is cleared (was out of bounds)
        XCTAssertNil(viewModel.selectedDayIndex)
    }

    func testUpdateEntriesKeepsValidSelection() {
        // Given: Selection at index 2
        let entries = DailyScoreEntry.sampleWeek
        viewModel.updateEntries(entries)
        viewModel.toggleSelection(for: 2)

        // When: Update with same number of entries
        viewModel.updateEntries(entries)

        // Then: Selection remains
        XCTAssertEqual(viewModel.selectedDayIndex, 2)
    }

    // MARK: - Selected Entry Tests

    func testSelectedEntryReturnsCorrectEntry() {
        // Given: Entries and a selection
        let entries = DailyScoreEntry.sampleWeek
        viewModel.updateEntries(entries)
        viewModel.toggleSelection(for: 3)

        // Then: Selected entry matches
        XCTAssertEqual(viewModel.selectedEntry?.id, entries[3].id)
    }

    func testSelectedEntryIsNilWhenNoSelection() {
        // Given: Entries but no selection
        viewModel.updateEntries(DailyScoreEntry.sampleWeek)

        // Then: Selected entry is nil
        XCTAssertNil(viewModel.selectedEntry)
    }

    // MARK: - Tooltip Tests

    func testSelectedDayTooltipFormat() {
        // Given: A selection with known score
        let entries = createEntriesWithKnownScores()
        viewModel.updateEntries(entries)
        viewModel.toggleSelection(for: 2)

        // Then: Tooltip contains day name and score
        let tooltip = viewModel.selectedDayTooltip
        XCTAssertNotNil(tooltip)
        // Format should be like "Wed • Score 75"
        XCTAssertTrue(tooltip?.contains("•") ?? false)
        XCTAssertTrue(tooltip?.contains("Score") ?? false)
    }

    func testSelectedDayTooltipIsNilWithNoSelection() {
        // Given: Entries but no selection
        viewModel.updateEntries(DailyScoreEntry.sampleWeek)

        // Then: Tooltip is nil
        XCTAssertNil(viewModel.selectedDayTooltip)
    }

    // MARK: - Delta Calculation Tests

    func testDeltaCalculationReturnsCorrectDifference() {
        // Given: Entries with known scores and a selection
        let entries = createEntriesWithKnownScores()
        viewModel.updateEntries(entries)
        viewModel.toggleSelection(for: 2) // Score 85, previous day score 70

        // Then: Delta is calculated correctly
        let delta = viewModel.selectedDayDelta
        XCTAssertNotNil(delta)
        XCTAssertEqual(delta?.value, 15) // 85 - 70
        XCTAssertTrue(delta?.isPositive ?? false)
    }

    func testDeltaNegativeWhenScoreDecreases() {
        // Given: Entries where selected day has lower score than previous
        let entries = createEntriesWithDecreasingScores()
        viewModel.updateEntries(entries)
        viewModel.toggleSelection(for: 2) // Score 60, previous score 75

        // Then: Delta is negative
        let delta = viewModel.selectedDayDelta
        XCTAssertNotNil(delta)
        XCTAssertTrue(delta?.value ?? 0 < 0)
        XCTAssertTrue(delta?.isNegative ?? false)
    }

    func testDeltaIsNilForFirstDayWithActivity() {
        // Given: Entries where first day is selected
        let entries = createEntriesWithKnownScores()
        viewModel.updateEntries(entries)
        viewModel.toggleSelection(for: 0)

        // Then: No delta (no previous day to compare)
        XCTAssertNil(viewModel.selectedDayDelta)
    }

    // MARK: - Helper Methods

    private func createEntriesWithKnownScores() -> [DailyScoreEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let scores = [65, 70, 85, 80, 90, 75, 82]

        return scores.enumerated().map { index, score in
            let date = calendar.date(byAdding: .day, value: -(6 - index), to: today)!
            return DailyScoreEntry(
                date: date,
                score: score,
                minutesCompleted: score > 0 ? 10 : 0,
                sessionsCompleted: score > 0 ? 2 : 0,
                focusAreas: ["neck", "shoulders"]
            )
        }
    }

    private func createEntriesWithDecreasingScores() -> [DailyScoreEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let scores = [80, 75, 60, 55, 50, 45, 40]

        return scores.enumerated().map { index, score in
            let date = calendar.date(byAdding: .day, value: -(6 - index), to: today)!
            return DailyScoreEntry(
                date: date,
                score: score,
                minutesCompleted: 10,
                sessionsCompleted: 2,
                focusAreas: ["neck"]
            )
        }
    }
}
