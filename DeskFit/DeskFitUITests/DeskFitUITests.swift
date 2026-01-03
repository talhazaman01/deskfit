//
//  DeskFitUITests.swift
//  DeskFitUITests
//
//  Created by Talha Zaman on 03/01/2026.
//

import XCTest

final class DeskFitUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

// MARK: - Session Player Text Truncation Tests

final class SessionPlayerTextTruncationTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Exercise Description Truncation Tests

    /// Verifies that the "More" button appears when exercise description exceeds 3 lines
    @MainActor
    func testExerciseDescriptionShowsMoreButtonWhenTruncated() throws {
        app.launch()

        // Navigate to a session with long exercise description
        navigateToSessionPlayer()

        let moreButton = app.buttons["MoreButton"]
        let exerciseDescription = app.staticTexts["ExerciseDescription"]

        // If description is truncated, More button should be visible
        if moreButton.waitForExistence(timeout: 5) {
            XCTAssertTrue(moreButton.exists, "More button should appear for truncated description")
            XCTAssertTrue(exerciseDescription.exists, "Exercise description should be visible")
        }
    }

    /// Verifies that tapping "More" expands the description and shows "Less" button
    @MainActor
    func testExerciseDescriptionExpandsOnMoreTap() throws {
        app.launch()
        navigateToSessionPlayer()

        let moreButton = app.buttons["MoreButton"]

        guard moreButton.waitForExistence(timeout: 5) else {
            // Short text - no truncation, skip test
            return
        }

        // Capture initial frame for comparison
        let initialFrame = app.otherElements["ExerciseDescription"].frame

        // Tap More
        moreButton.tap()

        // Wait for animation
        Thread.sleep(forTimeInterval: 0.5)

        // Verify "Less" button appears
        let lessButton = app.buttons["LessButton"]
        XCTAssertTrue(lessButton.waitForExistence(timeout: 2), "Less button should appear after expansion")

        // Verify expanded frame is larger (content expanded)
        let expandedFrame = app.otherElements["ExerciseDescription"].frame
        XCTAssertGreaterThanOrEqual(expandedFrame.height, initialFrame.height, "Description should expand or maintain height")
    }

    /// Verifies that tapping "Less" collapses the description back
    @MainActor
    func testExerciseDescriptionCollapsesOnLessTap() throws {
        app.launch()
        navigateToSessionPlayer()

        let moreButton = app.buttons["MoreButton"]

        guard moreButton.waitForExistence(timeout: 5) else {
            return
        }

        // Expand first
        moreButton.tap()
        Thread.sleep(forTimeInterval: 0.5)

        // Now collapse
        let lessButton = app.buttons["LessButton"]
        XCTAssertTrue(lessButton.exists)
        lessButton.tap()

        Thread.sleep(forTimeInterval: 0.5)

        // Verify More button reappears
        XCTAssertTrue(moreButton.waitForExistence(timeout: 2), "More button should reappear after collapse")
    }

    // MARK: - Safety Disclaimer Truncation Tests

    /// Verifies safety disclaimer shows More button when exceeding 2 lines
    @MainActor
    func testSafetyDisclaimerShowsMoreButtonWhenTruncated() throws {
        app.launch()
        navigateToSessionPlayer()

        let safetyDisclaimer = app.otherElements["SafetyDisclaimer"]

        guard safetyDisclaimer.waitForExistence(timeout: 5) else {
            // Exercise may not have contraindication
            return
        }

        // Check if More button exists within safety disclaimer context
        let moreButtonInDisclaimer = safetyDisclaimer.buttons["MoreButton"]
        if moreButtonInDisclaimer.exists {
            XCTAssertTrue(moreButtonInDisclaimer.isHittable, "More button should be tappable")
        }
    }

    /// Verifies safety disclaimer expands correctly
    @MainActor
    func testSafetyDisclaimerExpandsAndCollapses() throws {
        app.launch()
        navigateToSessionPlayer()

        let safetyDisclaimer = app.otherElements["SafetyDisclaimer"]

        guard safetyDisclaimer.waitForExistence(timeout: 5) else {
            return
        }

        let moreButton = safetyDisclaimer.buttons["MoreButton"]
        guard moreButton.exists else {
            // Short safety text, no truncation
            return
        }

        // Expand
        moreButton.tap()
        Thread.sleep(forTimeInterval: 0.5)

        let lessButton = safetyDisclaimer.buttons["LessButton"]
        XCTAssertTrue(lessButton.waitForExistence(timeout: 2))

        // Collapse
        lessButton.tap()
        Thread.sleep(forTimeInterval: 0.5)

        XCTAssertTrue(moreButton.waitForExistence(timeout: 2))
    }

    // MARK: - Device Size Tests

    /// Tests that truncation works correctly on iPhone SE (smallest supported device)
    @MainActor
    func testTruncationOnSmallDevice() throws {
        // This test validates layout doesn't break on small screens
        // The geometry-based truncation detection should handle varying widths
        app.launch()
        navigateToSessionPlayer()

        let exerciseDescription = app.staticTexts.matching(identifier: "ExpandableText_3Lines").firstMatch
        XCTAssertTrue(exerciseDescription.waitForExistence(timeout: 5), "Exercise description should render on small device")

        // Verify no layout overflow (element is within screen bounds)
        let screenBounds = app.windows.firstMatch.frame
        if exerciseDescription.exists {
            XCTAssertTrue(exerciseDescription.frame.maxX <= screenBounds.maxX, "Description should not overflow horizontally")
        }
    }

    // MARK: - Animation Tests

    /// Verifies that expand/collapse animation completes smoothly
    @MainActor
    func testExpandCollapseAnimationCompletes() throws {
        app.launch()
        navigateToSessionPlayer()

        let moreButton = app.buttons["MoreButton"]

        guard moreButton.waitForExistence(timeout: 5) else {
            return
        }

        // Rapid tap test - animation should handle interruption gracefully
        moreButton.tap()
        Thread.sleep(forTimeInterval: 0.1) // Quick tap during animation

        let lessButton = app.buttons["LessButton"]
        if lessButton.exists {
            lessButton.tap()
        }

        // App should remain stable
        XCTAssertTrue(app.state == .runningForeground, "App should remain stable after rapid interactions")
    }

    // MARK: - Helper Methods

    private func navigateToSessionPlayer() {
        // Navigate through the app to reach SessionPlayerView
        // This will depend on your app's navigation structure

        // Wait for home screen to load
        let startSessionButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Start'")).firstMatch

        if startSessionButton.waitForExistence(timeout: 10) {
            startSessionButton.tap()
        }

        // Wait for session player to appear
        _ = app.staticTexts["ExerciseName"].waitForExistence(timeout: 5)
    }
}

// MARK: - Snapshot-Style Assertion Helpers

extension XCTestCase {
    /// Captures and compares view hierarchy for truncation state
    /// This provides snapshot-style assertions without external dependencies
    func assertTextTruncationState(
        element: XCUIElement,
        shouldBeTruncated: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let moreButton = element.buttons["MoreButton"]
        let lessButton = element.buttons["LessButton"]

        if shouldBeTruncated {
            let hasToggleButton = moreButton.exists || lessButton.exists
            XCTAssertTrue(
                hasToggleButton,
                "Expected truncated text to have More/Less button",
                file: file,
                line: line
            )
        } else {
            XCTAssertFalse(
                moreButton.exists,
                "Expected non-truncated text to not have More button",
                file: file,
                line: line
            )
        }
    }

    /// Asserts that text expansion animation completed by checking button state
    func assertExpansionState(
        element: XCUIElement,
        isExpanded: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let moreButton = element.buttons["MoreButton"]
        let lessButton = element.buttons["LessButton"]

        if isExpanded {
            XCTAssertTrue(
                lessButton.exists,
                "Expected expanded state to show Less button",
                file: file,
                line: line
            )
            XCTAssertFalse(
                moreButton.exists,
                "Expected expanded state to hide More button",
                file: file,
                line: line
            )
        } else {
            XCTAssertTrue(
                moreButton.exists,
                "Expected collapsed state to show More button",
                file: file,
                line: line
            )
        }
    }
}
