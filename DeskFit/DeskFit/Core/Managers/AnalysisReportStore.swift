import Foundation

/// Persistent storage for AnalysisReport.
/// Uses file-based JSON storage for reliability and future flexibility.
final class AnalysisReportStore: Sendable {
    static let shared = AnalysisReportStore()

    private let fileManager = FileManager.default
    private let fileName = "analysis_report.json"

    private var fileURL: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }

    private init() {}

    // MARK: - Public API

    /// Save the analysis report to persistent storage
    func save(_ report: AnalysisReport) {
        guard let url = fileURL else {
            print("AnalysisReportStore: Failed to get file URL")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(report)
            try data.write(to: url, options: .atomic)
            #if DEBUG
            print("AnalysisReportStore: Saved report with score \(report.score.value)")
            #endif
        } catch {
            print("AnalysisReportStore: Failed to save report - \(error.localizedDescription)")
        }
    }

    /// Load the most recent analysis report from storage
    func load() -> AnalysisReport? {
        guard let url = fileURL else {
            print("AnalysisReportStore: Failed to get file URL")
            return nil
        }

        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let report = try decoder.decode(AnalysisReport.self, from: data)
            return report
        } catch {
            print("AnalysisReportStore: Failed to load report - \(error.localizedDescription)")
            return nil
        }
    }

    /// Check if a report exists in storage
    var hasStoredReport: Bool {
        guard let url = fileURL else { return false }
        return fileManager.fileExists(atPath: url.path)
    }

    /// Delete the stored report
    func delete() {
        guard let url = fileURL else { return }

        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
                #if DEBUG
                print("AnalysisReportStore: Deleted stored report")
                #endif
            }
        } catch {
            print("AnalysisReportStore: Failed to delete report - \(error.localizedDescription)")
        }
    }

    /// Get the creation date of the stored report without loading the full report
    func storedReportDate() -> Date? {
        load()?.createdAt
    }
}

// MARK: - Convenience Extensions

extension AnalysisReportStore {
    /// Generate and save a new report from profile
    func generateAndSave(from profile: OnboardingProfileSnapshot) -> AnalysisReport {
        let report = AnalysisEngine.shared.generate(profile: profile)
        save(report)
        return report
    }

    /// Generate and save a new report from UserProfile
    func generateAndSave(from userProfile: UserProfile) -> AnalysisReport {
        let snapshot = OnboardingProfileSnapshot.from(profile: userProfile)
        return generateAndSave(from: snapshot)
    }
}
