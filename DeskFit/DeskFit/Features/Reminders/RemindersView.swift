import SwiftUI
import SwiftData
import Combine

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @StateObject private var viewModel = RemindersViewModel()

    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        Form {
            Section {
                Toggle("Reminders", isOn: $viewModel.remindersEnabled)
                    .onChange(of: viewModel.remindersEnabled) { _, newValue in
                        handleToggle(enabled: newValue)
                    }
            }

            if viewModel.remindersEnabled {
                Section("Frequency") {
                    Picker("Remind me", selection: $viewModel.frequency) {
                        ForEach(ReminderFrequency.allCases.filter { $0 != .off }) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    .onChange(of: viewModel.frequency) { _, _ in
                        updateReminders()
                    }
                }

                Section("Work Hours") {
                    TimePickerRow(label: "Start", minutesSinceMidnight: $viewModel.workStartMinutes)
                        .onChange(of: viewModel.workStartMinutes) { _, _ in updateReminders() }

                    TimePickerRow(label: "End", minutesSinceMidnight: $viewModel.workEndMinutes)
                        .onChange(of: viewModel.workEndMinutes) { _, _ in updateReminders() }
                }

                if viewModel.workEndMinutes <= viewModel.workStartMinutes {
                    Section {
                        Label("End time must be after start time", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.warning)
                            .font(Theme.Typography.caption)
                    }
                }
            }

            if viewModel.permissionDenied {
                Section {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Label("Notifications are disabled", systemImage: "bell.slash")
                            .foregroundStyle(.warning)

                        Text("Enable notifications in Settings to receive break reminders.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textSecondary)

                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(Theme.Typography.subtitle)
                        .foregroundStyle(.appTeal)
                    }
                }
            }
        }
        .navigationTitle("Reminders")
        .onAppear {
            loadFromProfile()
            checkPermission()
        }
    }

    private func loadFromProfile() {
        guard let profile = profile else { return }
        viewModel.frequency = ReminderFrequency(rawValue: profile.reminderFrequency) ?? .every2Hours
        viewModel.remindersEnabled = viewModel.frequency != .off
        viewModel.workStartMinutes = profile.workStartMinutes
        viewModel.workEndMinutes = profile.workEndMinutes
    }

    private func checkPermission() {
        Task {
            let status = await NotificationService.shared.checkPermissionStatus()
            await MainActor.run {
                viewModel.permissionDenied = status == .denied
            }
        }
    }

    private func handleToggle(enabled: Bool) {
        if enabled {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                await MainActor.run {
                    if granted {
                        updateReminders()
                    } else {
                        viewModel.permissionDenied = true
                        viewModel.remindersEnabled = false
                    }
                }
            }
        } else {
            viewModel.frequency = .off
            saveToProfile()
            Task {
                await NotificationService.shared.cancelAllReminders()
            }
        }
    }

    private func updateReminders() {
        guard viewModel.workEndMinutes > viewModel.workStartMinutes else { return }

        saveToProfile()

        Task {
            await NotificationService.shared.scheduleReminders(
                frequency: viewModel.frequency,
                workStartMinutes: viewModel.workStartMinutes,
                workEndMinutes: viewModel.workEndMinutes
            )
        }
    }

    private func saveToProfile() {
        guard let profile = profile else { return }
        profile.reminderFrequency = viewModel.remindersEnabled ? viewModel.frequency.rawValue : ReminderFrequency.off.rawValue
        profile.workStartMinutes = viewModel.workStartMinutes
        profile.workEndMinutes = viewModel.workEndMinutes
        try? modelContext.save()

        AnalyticsService.shared.track(.settingsChanged(
            setting: "reminder_frequency",
            newValue: profile.reminderFrequency
        ))
    }
}
