import Foundation

@MainActor
class RemindersViewModel: ObservableObject {
    @Published var remindersEnabled = true
    @Published var frequency: ReminderFrequency = .every2Hours
    @Published var workStartMinutes: Int = 540   // 9:00 AM
    @Published var workEndMinutes: Int = 1020    // 5:00 PM
    @Published var permissionDenied = false
}
