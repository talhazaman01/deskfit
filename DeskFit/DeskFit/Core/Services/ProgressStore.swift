import Foundation
import Combine

// MARK: - Progress Store

/// Persistent storage for daily score entries and progress data.
/// Uses file-based JSON storage for reliability.
@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    private let fileManager = FileManager.default
    private let fileName = "progress_entries.json"

    /// All stored daily entries
    @Published private(set) var entries: [DailyScoreEntry] = []

    /// Current progress summary
    @Published private(set) var currentSummary: ProgressSummary = .empty()

    private var fileURL: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }

    private init() {
        loadEntries()
        updateSummary()
    }

    // MARK: - Public API

    /// Save or update a daily score entry
    func saveEntry(_ entry: DailyScoreEntry) {
        let entryDate = Calendar.current.startOfDay(for: entry.date)

        // Remove existing entry for the same date
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: entryDate) }

        // Add new entry
        entries.append(entry)

        // Sort by date (most recent first)
        entries.sort { $0.date > $1.date }

        // Persist
        persistEntries()
        updateSummary()

        #if DEBUG
        print("ProgressStore: Saved entry for \(entry.displayDate) with score \(entry.score)")
        #endif
    }

    /// Get entry for a specific date
    func entry(for date: Date) -> DailyScoreEntry? {
        entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    /// Get today's entry
    func todaysEntry() -> DailyScoreEntry? {
        entry(for: Date())
    }

    /// Get entries for the last N days
    func entries(forLastDays days: Int) -> [DailyScoreEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today)!

        return entries.filter { $0.date >= startDate }
            .sorted { $0.date > $1.date }
    }

    /// Get entries for a specific date range
    func entries(from startDate: Date, to endDate: Date) -> [DailyScoreEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        return entries.filter { $0.date >= start && $0.date <= end }
            .sorted { $0.date > $1.date }
    }

    /// Delete entry for a specific date
    func deleteEntry(for date: Date) {
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        persistEntries()
        updateSummary()
    }

    /// Clear all entries (for testing/reset)
    func clearAll() {
        entries.removeAll()
        persistEntries()
        updateSummary()
    }

    /// Force reload from disk
    func reload() {
        loadEntries()
        updateSummary()
    }

    // MARK: - Session Recording Integration

    /// Record a completed session and update today's score
    func recordSessionCompletion(
        durationSeconds: Int,
        focusAreas: [String],
        profile: OnboardingProfileSnapshot?,
        currentStreak: Int
    ) {
        let today = Date()
        let sessionTime = ScoreEngine.shared.sessionTimeCategory(for: today)

        // Get or create today's entry
        let currentEntry = todaysEntry()
        let newSessionsCompleted = (currentEntry?.sessionsCompleted ?? 0) + 1
        let newMinutesCompleted = (currentEntry?.minutesCompleted ?? 0) + (durationSeconds / 60)

        // Merge focus areas
        var allFocusAreas = Set(currentEntry?.focusAreas ?? [])
        allFocusAreas.formUnion(focusAreas)

        // Track stiffness times
        var stiffnessTimes = Set(currentEntry?.stiffnessTimesTriggered ?? [])
        stiffnessTimes.insert(sessionTime.rawValue)

        // Calculate new score
        let newEntry = ScoreEngine.shared.calculateDailyScore(
            for: today,
            sessionsCompleted: newSessionsCompleted,
            minutesCompleted: newMinutesCompleted,
            focusAreas: Array(allFocusAreas),
            stiffnessTimesTriggered: Array(stiffnessTimes),
            profile: profile,
            currentStreak: currentStreak
        )

        saveEntry(newEntry)

        // Track analytics
        AnalyticsService.shared.track(.sessionCompleted(
            sessionId: UUID().uuidString,
            durationSeconds: durationSeconds,
            feedback: nil
        ))
    }

    // MARK: - Summary Generation

    /// Update the current progress summary
    func updateSummary() {
        let last7Days = entries(forLastDays: 7)

        // Calculate week start (Monday)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        let weekStart = calendar.date(from: components) ?? Date()

        // Calculate metrics
        let weeklyAverage = ScoreEngine.shared.calculateWeeklyAverage(from: last7Days)
        let totalSessions = ScoreEngine.shared.calculateTotalSessions(from: last7Days)
        let totalMinutes = ScoreEngine.shared.calculateTotalMinutes(from: last7Days)
        let focusAreas = ScoreEngine.shared.collectFocusAreas(from: last7Days)

        // Calculate streak from entries
        let streak = calculateCurrentStreak()

        // Generate wins
        let trend = calculateTrend(from: last7Days)
        let wins = WinGenerator.generateWins(
            streakDays: streak,
            weeklySessionsCompleted: totalSessions,
            weeklyAverageScore: weeklyAverage,
            trend: trend,
            focusAreasCovered: focusAreas
        )

        // Fill in missing days for chart display
        let filledDays = fillMissingDays(from: last7Days)

        currentSummary = ProgressSummary(
            weekStartDate: weekStart,
            weeklyAverageScore: weeklyAverage,
            weeklySessionsCompleted: totalSessions,
            weeklyMinutesCompleted: totalMinutes,
            streakDays: streak,
            last7Days: filledDays,
            wins: wins
        )
    }

    // MARK: - Private Methods

    private func loadEntries() {
        guard let url = fileURL else {
            print("ProgressStore: Failed to get file URL")
            return
        }

        guard fileManager.fileExists(atPath: url.path) else {
            entries = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            entries = try decoder.decode([DailyScoreEntry].self, from: data)
            entries.sort { $0.date > $1.date }
            #if DEBUG
            print("ProgressStore: Loaded \(entries.count) entries")
            #endif
        } catch {
            print("ProgressStore: Failed to load entries - \(error.localizedDescription)")
            entries = []
        }
    }

    private func persistEntries() {
        guard let url = fileURL else {
            print("ProgressStore: Failed to get file URL")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(entries)
            try data.write(to: url, options: .atomic)
        } catch {
            print("ProgressStore: Failed to save entries - \(error.localizedDescription)")
        }
    }

    private func calculateCurrentStreak() -> Int {
        guard !entries.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today

        // Check if there's activity today
        let todayHasActivity = entries.first { calendar.isDate($0.date, inSameDayAs: today) }?.hasActivity ?? false

        if !todayHasActivity {
            // Start checking from yesterday
            checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
        }

        // Count consecutive days with activity
        while true {
            let entryForDay = entries.first { calendar.isDate($0.date, inSameDayAs: checkDate) }

            if let entry = entryForDay, entry.hasActivity {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }

        return streak
    }

    private func calculateTrend(from entries: [DailyScoreEntry]) -> ProgressTrend {
        let activeDays = entries.filter { $0.hasActivity }
        guard activeDays.count >= 3 else { return .neutral }

        let scores = activeDays.map { $0.score }
        let firstHalf = scores.prefix(scores.count / 2)
        let secondHalf = scores.suffix(scores.count / 2)

        guard !firstHalf.isEmpty && !secondHalf.isEmpty else { return .neutral }

        let firstAvg = firstHalf.reduce(0, +) / firstHalf.count
        let secondAvg = secondHalf.reduce(0, +) / secondHalf.count

        if secondAvg > firstAvg + 5 {
            return .improving
        } else if secondAvg < firstAvg - 5 {
            return .declining
        }
        return .neutral
    }

    /// Fill in missing days for chart display
    private func fillMissingDays(from existingEntries: [DailyScoreEntry]) -> [DailyScoreEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var result: [DailyScoreEntry] = []

        for dayOffset in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!

            if let existing = existingEntries.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                result.append(existing)
            } else {
                // Create empty placeholder entry
                result.append(DailyScoreEntry(
                    date: date,
                    score: 0,
                    minutesCompleted: 0,
                    sessionsCompleted: 0,
                    focusAreas: []
                ))
            }
        }

        return result
    }
}

// MARK: - Convenience Extensions

extension ProgressStore {
    /// Check if user has any progress data
    var hasProgressData: Bool {
        !entries.isEmpty
    }

    /// Get the most recent score
    var latestScore: Int? {
        entries.first?.score
    }

    /// Days since last activity
    var daysSinceLastActivity: Int? {
        guard let lastEntry = entries.first(where: { $0.hasActivity }) else { return nil }
        return Calendar.current.dateComponents([.day], from: lastEntry.date, to: Date()).day
    }
}
