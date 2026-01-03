import Foundation
import Combine

enum OnboardingPhase {
    case questionnaire  // Steps 0-4: goal, focus, time, hours, reminders
    case summary        // "Your plan is ready" screen
    case starterReset   // 60s starter session
    case completion     // Post-reset completion screen
}

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var selectedGoal: UserGoal?
    @Published var selectedFocusAreas: Set<FocusArea> = []
    @Published var selectedDailyTime: Int = 5

    @Published var workStartMinutes: Int = 540   // 9:00 AM
    @Published var workEndMinutes: Int = 1020    // 5:00 PM

    @Published var reminderFrequency: ReminderFrequency = .every2Hours

    // New state for extended flow
    @Published var currentPhase: OnboardingPhase = .questionnaire
    @Published var starterResetDuration: Int = 0  // Actual duration completed

    var startTime: Date?
}
