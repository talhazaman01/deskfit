import Foundation
import Combine

enum OnboardingPhase {
    case questionnaire  // Steps 0-9: goal, focus, stiffness, dob, gender, height/weight, time, hours, reminders, airpods
    case summary        // "Your plan is ready" screen
    case safety         // Safety acknowledgment screen (before starter reset)
    case starterReset   // 60s starter session
    case analysis       // Personalized analysis screen (before plan reveal)
    case planPreview    // 7-day plan preview screen
    case completion     // Post-reset completion screen (fallback if plan generation fails)
}

@MainActor
class OnboardingViewModel: ObservableObject {
    // Step 0: Goal
    @Published var selectedGoal: UserGoal?

    // Step 1: Focus Areas
    @Published var selectedFocusAreas: Set<FocusArea> = []

    // Step 2: Stiffness Times (multi-select)
    @Published var selectedStiffnessTimes: Set<StiffnessTime> = []

    // Step 3: Date of Birth
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @Published var hasSetDateOfBirth: Bool = false

    // Step 4: Gender
    @Published var selectedGender: Gender?

    // Step 5: Height & Weight
    @Published var measurementUnit: MeasurementUnit = .imperial
    @Published var heightFeet: Int = 5
    @Published var heightInches: Int = 7
    @Published var heightCm: Int = 170
    @Published var weightLb: Int = 150
    @Published var weightKg: Int = 68
    @Published var hasEnteredHeight: Bool = false
    @Published var hasEnteredWeight: Bool = false

    // Step 6: Time Preference
    @Published var selectedDailyTime: Int = 5

    // Step 7: Work Hours
    @Published var workStartMinutes: Int = 540   // 9:00 AM
    @Published var workEndMinutes: Int = 1020    // 5:00 PM
    @Published var sedentaryHoursBucket: SedentaryHoursBucket?  // Optional sedentary hours

    // Step 8: Reminder Frequency
    @Published var reminderFrequency: ReminderFrequency = .every2Hours

    // Step 9: AirPods
    @Published var airpodsResponse: AirPodsOnboardingResponse?

    // Flow state
    @Published var currentPhase: OnboardingPhase = .questionnaire
    @Published var starterResetDuration: Int = 0  // Actual duration completed

    /// Generated weekly plan result (created after starter reset)
    @Published var generatedPlanResult: PlanGenerationResult?

    /// Generated analysis report (created after starter reset, before plan preview)
    @Published var generatedAnalysisReport: AnalysisReport?

    var startTime: Date?

    // MARK: - Computed Properties

    /// Analytics value for stiffness times selection
    /// Returns "all_day" if all 3 selected, otherwise comma-separated sorted list
    var stiffnessTimesAnalyticsValue: String {
        if selectedStiffnessTimes.count == StiffnessTime.allCases.count {
            return "all_day"
        }
        return selectedStiffnessTimes
            .map { $0.rawValue }
            .sorted()
            .joined(separator: ",")
    }

    /// Age calculated from date of birth
    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year ?? 0
    }

    /// Height in cm for storage (converts imperial if needed)
    var heightCmForStorage: Double? {
        guard hasEnteredHeight else { return nil }
        switch measurementUnit {
        case .metric:
            return Double(heightCm)
        case .imperial:
            // Convert feet/inches to cm: (feet * 12 + inches) * 2.54
            let totalInches = Double(heightFeet * 12 + heightInches)
            return totalInches * 2.54
        }
    }

    /// Weight in kg for storage (converts imperial if needed)
    var weightKgForStorage: Double? {
        guard hasEnteredWeight else { return nil }
        switch measurementUnit {
        case .metric:
            return Double(weightKg)
        case .imperial:
            // Convert lb to kg: lb * 0.453592
            return Double(weightLb) * 0.453592
        }
    }

    /// Whether the DOB is valid (age >= 13)
    var isDateOfBirthValid: Bool {
        age >= 13
    }

    // MARK: - Height/Weight Validation

    /// Height is in realistic range
    var isHeightValid: Bool {
        if !hasEnteredHeight { return true } // Optional field
        switch measurementUnit {
        case .metric:
            return heightCm >= 100 && heightCm <= 250
        case .imperial:
            let totalInches = heightFeet * 12 + heightInches
            return totalInches >= 40 && totalInches <= 100 // ~3'4" to 8'4"
        }
    }

    /// Weight is in realistic range
    var isWeightValid: Bool {
        if !hasEnteredWeight { return true } // Optional field
        switch measurementUnit {
        case .metric:
            return weightKg >= 30 && weightKg <= 300
        case .imperial:
            return weightLb >= 66 && weightLb <= 660
        }
    }
}
