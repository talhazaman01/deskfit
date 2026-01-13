//
//  StiffnessTimeToggleTests.swift
//  DeskFitTests
//
//  Tests for StiffnessTime.toggle() selection rules
//

import Testing
@testable import DeskFit

struct StiffnessTimeToggleTests {

    // MARK: - Tapping "All day" Tests

    @Test("Tapping allDay from empty selection returns just allDay")
    func testTapAllDayFromEmpty() {
        let current: Set<StiffnessTime> = []
        let result = StiffnessTime.toggle(.allDay, in: current)
        #expect(result == [.allDay])
    }

    @Test("Tapping allDay from single selection returns just allDay")
    func testTapAllDayFromSingleSelection() {
        let current: Set<StiffnessTime> = [.morning]
        let result = StiffnessTime.toggle(.allDay, in: current)
        #expect(result == [.allDay])
    }

    @Test("Tapping allDay from multiple selections returns just allDay")
    func testTapAllDayFromMultipleSelections() {
        let current: Set<StiffnessTime> = [.morning, .midday, .evening]
        let result = StiffnessTime.toggle(.allDay, in: current)
        #expect(result == [.allDay])
    }

    @Test("Tapping allDay when already selected unselects it (returns empty)")
    func testTapAllDayWhenAlreadySelected() {
        let current: Set<StiffnessTime> = [.allDay]
        let result = StiffnessTime.toggle(.allDay, in: current)
        #expect(result.isEmpty)
    }

    // MARK: - Tapping Individual Times from allDay Tests

    @Test("Tapping morning when allDay selected clears allDay and selects morning")
    func testTapMorningFromAllDay() {
        let current: Set<StiffnessTime> = [.allDay]
        let result = StiffnessTime.toggle(.morning, in: current)
        #expect(result == [.morning])
        #expect(!result.contains(.allDay))
    }

    @Test("Tapping midday when allDay selected clears allDay and selects midday")
    func testTapMiddayFromAllDay() {
        let current: Set<StiffnessTime> = [.allDay]
        let result = StiffnessTime.toggle(.midday, in: current)
        #expect(result == [.midday])
    }

    @Test("Tapping evening when allDay selected clears allDay and selects evening")
    func testTapEveningFromAllDay() {
        let current: Set<StiffnessTime> = [.allDay]
        let result = StiffnessTime.toggle(.evening, in: current)
        #expect(result == [.evening])
    }

    // MARK: - Tapping Individual Times (Normal Toggle) Tests

    @Test("Tapping morning from empty adds morning")
    func testTapMorningFromEmpty() {
        let current: Set<StiffnessTime> = []
        let result = StiffnessTime.toggle(.morning, in: current)
        #expect(result == [.morning])
    }

    @Test("Tapping evening when morning and midday selected adds evening")
    func testAddThirdIndividualTime() {
        let current: Set<StiffnessTime> = [.morning, .midday]
        let result = StiffnessTime.toggle(.evening, in: current)
        #expect(result == [.morning, .midday, .evening])
    }

    @Test("Tapping morning when morning is selected removes morning")
    func testRemoveMorningWhenSelected() {
        let current: Set<StiffnessTime> = [.morning]
        let result = StiffnessTime.toggle(.morning, in: current)
        #expect(result.isEmpty)
    }

    @Test("Tapping morning when morning and midday are selected removes only morning")
    func testRemoveMorningFromMultiple() {
        let current: Set<StiffnessTime> = [.morning, .midday]
        let result = StiffnessTime.toggle(.morning, in: current)
        #expect(result == [.midday])
    }

    // MARK: - Individual Cases Array Tests

    @Test("Individual cases excludes allDay")
    func testIndividualCases() {
        let individualCases = StiffnessTime.individualCases
        #expect(individualCases.count == 3)
        #expect(individualCases.contains(.morning))
        #expect(individualCases.contains(.midday))
        #expect(individualCases.contains(.evening))
        #expect(!individualCases.contains(.allDay))
    }

    // MARK: - Display Properties Tests

    @Test("AllDay has correct display properties")
    func testAllDayDisplayProperties() {
        #expect(StiffnessTime.allDay.displayName == "All day")
        #expect(StiffnessTime.allDay.description == "It varies throughout my workday")
        #expect(StiffnessTime.allDay.icon == "clock.fill")
        #expect(StiffnessTime.allDay.rawValue == "all_day")
    }
}
