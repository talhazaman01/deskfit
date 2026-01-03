import Foundation
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var selectedGoal: UserGoal?
    @Published var selectedFocusAreas: Set<FocusArea> = []
    @Published var selectedDailyTime: Int = 5

    @Published var workStartMinutes: Int = 540   // 9:00 AM
    @Published var workEndMinutes: Int = 1020    // 5:00 PM

    @Published var reminderFrequency: ReminderFrequency = .every2Hours

    var startTime: Date?
}
