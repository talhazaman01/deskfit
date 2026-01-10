import Foundation
import SwiftUI

// MARK: - Weekly Chart View Model

/// ViewModel for the interactive weekly progress chart.
/// Handles selection state, delta calculations, and display labels.
@MainActor
final class WeeklyChartViewModel: ObservableObject {

    // MARK: - Published State

    /// Currently selected day (nil = no selection)
    @Published var selectedDayIndex: Int?

    /// Animation state for selection
    @Published var selectionScale: CGFloat = 1.0

    // MARK: - Properties

    /// The entries being displayed
    private(set) var entries: [DailyScoreEntry] = []

    // MARK: - Selection

    /// Toggle selection for a day. If already selected, deselect.
    func toggleSelection(for index: Int) {
        if selectedDayIndex == index {
            // Deselect
            selectedDayIndex = nil
        } else {
            // Select new day
            selectedDayIndex = index

            // Track analytics
            if index < entries.count {
                let entry = entries[index]
                AnalyticsService.shared.track(.chartDaySelected(
                    dayIndex: index,
                    score: entry.score
                ))
            }
        }
    }

    /// Clear selection
    func clearSelection() {
        selectedDayIndex = nil
    }

    /// Update entries (called when data changes)
    func updateEntries(_ newEntries: [DailyScoreEntry]) {
        self.entries = newEntries

        // Clear selection if it's now out of bounds
        if let selected = selectedDayIndex, selected >= newEntries.count {
            selectedDayIndex = nil
        }
    }

    // MARK: - Display Helpers

    /// Get the selected entry, if any
    var selectedEntry: DailyScoreEntry? {
        guard let index = selectedDayIndex, index < entries.count else { return nil }
        return entries[index]
    }

    /// Get tooltip text for selected day
    var selectedDayTooltip: String? {
        guard let entry = selectedEntry else { return nil }
        let dayName = entry.shortDayName
        let score = entry.score
        return "\(dayName) • Score \(score)"
    }

    /// Get delta text comparing selected day to previous day
    var selectedDayDelta: DeltaInfo? {
        guard let index = selectedDayIndex, index < entries.count else { return nil }
        let entry = entries[index]

        // Find previous day with activity
        var previousIndex = index - 1
        while previousIndex >= 0 {
            let prev = entries[previousIndex]
            if prev.hasActivity {
                let delta = entry.score - prev.score
                return DeltaInfo(
                    value: delta,
                    previousDayName: prev.shortDayName
                )
            }
            previousIndex -= 1
        }

        return nil
    }

    /// Get streak info for selected day
    var selectedDayStreak: Int? {
        guard let index = selectedDayIndex, index < entries.count else { return nil }

        // Count consecutive days with activity ending at selected day
        var streak = 0
        var checkIndex = index

        while checkIndex >= 0 && entries[checkIndex].hasActivity {
            streak += 1
            checkIndex -= 1
        }

        return streak > 0 ? streak : nil
    }

    /// Get detail line for selected day (sessions + minutes)
    var selectedDayDetail: String? {
        guard let entry = selectedEntry, entry.hasActivity else { return nil }
        let sessions = entry.sessionsCompleted
        let sessionWord = sessions == 1 ? "session" : "sessions"
        let minutes = entry.minutesCompleted
        return "\(sessions) \(sessionWord) • \(minutes) min"
    }
}

// MARK: - Delta Info

struct DeltaInfo {
    let value: Int
    let previousDayName: String

    var displayText: String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(value) vs \(previousDayName)"
    }

    var isPositive: Bool {
        value > 0
    }

    var isNegative: Bool {
        value < 0
    }

    var isNeutral: Bool {
        value == 0
    }
}
