import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Query private var profiles: [UserProfile]

    @State private var showResetAlert = false
    @State private var isRestoringPurchases = false

    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        List {
            // Subscription Section
            Section {
                SubscriptionStatusRow(subscriptionManager: subscriptionManager)

                if !subscriptionManager.isProUser {
                    Button {
                        appState.presentPaywall(source: "settings")
                    } label: {
                        HStack {
                            Label("Upgrade to Pro", systemImage: "star.fill")
                                .foregroundStyle(.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.textSecondary)
                        }
                    }
                }

                Button {
                    Task {
                        isRestoringPurchases = true
                        await subscriptionManager.restorePurchases()
                        isRestoringPurchases = false
                    }
                } label: {
                    HStack {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                            .foregroundStyle(.textPrimary)
                        if isRestoringPurchases {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isRestoringPurchases)
            } header: {
                Text("Subscription")
            }

            // Preferences Section
            if let profile = profile {
                Section {
                    Toggle(isOn: Binding(
                        get: { profile.soundEnabled },
                        set: { newValue in
                            profile.soundEnabled = newValue
                            try? modelContext.save()
                        }
                    )) {
                        Label("Sounds", systemImage: "speaker.wave.2")
                    }

                    Toggle(isOn: Binding(
                        get: { profile.hapticsEnabled },
                        set: { newValue in
                            profile.hapticsEnabled = newValue
                            try? modelContext.save()
                        }
                    )) {
                        Label("Haptics", systemImage: "iphone.radiowaves.left.and.right")
                    }
                } header: {
                    Text("Preferences")
                }

                // Schedule Section
                Section {
                    NavigationLink {
                        WorkHoursEditView(profile: profile)
                    } label: {
                        HStack {
                            Label("Work Hours", systemImage: "clock")
                            Spacer()
                            Text(workHoursText(profile: profile))
                                .foregroundStyle(.textSecondary)
                        }
                    }

                    NavigationLink {
                        ReminderFrequencyEditView(profile: profile)
                    } label: {
                        HStack {
                            Label("Reminder Frequency", systemImage: "bell")
                            Spacer()
                            Text(reminderFrequencyText(profile: profile))
                                .foregroundStyle(.textSecondary)
                        }
                    }
                } header: {
                    Text("Schedule")
                }

                // Goals Section
                Section {
                    NavigationLink {
                        FocusAreasEditView(profile: profile)
                    } label: {
                        HStack {
                            Label("Focus Areas", systemImage: "figure.flexibility")
                            Spacer()
                            Text("\(profile.focusAreas.count) selected")
                                .foregroundStyle(.textSecondary)
                        }
                    }
                } header: {
                    Text("Goals")
                }
            }

            // Support Section
            Section {
                NavigationLink {
                    SafetyDisclaimerView()
                } label: {
                    Label("Safety & Disclaimer", systemImage: "heart.text.square")
                        .foregroundStyle(.textPrimary)
                }

                Link(destination: URL(string: "mailto:support@deskfit.app")!) {
                    Label("Contact Support", systemImage: "envelope")
                        .foregroundStyle(.textPrimary)
                }

                Link(destination: URL(string: "https://deskfit.app/privacy")!) {
                    Label("Privacy Policy", systemImage: "lock.shield")
                        .foregroundStyle(.textPrimary)
                }

                Link(destination: URL(string: "https://deskfit.app/terms")!) {
                    Label("Terms of Service", systemImage: "doc.text")
                        .foregroundStyle(.textPrimary)
                }
            } header: {
                Text("Support")
            }

            // Advanced Section
            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                }
            } header: {
                Text("Advanced")
            } footer: {
                Text("Version 1.0.0")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
            }
        }
        .scrollContentBackground(.hidden)
        .deskFitScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Onboarding?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetOnboarding()
            }
        } message: {
            Text("This will restart the onboarding process. Your session history will be preserved.")
        }
    }

    private func workHoursText(profile: UserProfile) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let start = formatter.string(from: profile.workStartTime)
        let end = formatter.string(from: profile.workEndTime)
        return "\(start) - \(end)"
    }

    private func reminderFrequencyText(profile: UserProfile) -> String {
        ReminderFrequency(rawValue: profile.reminderFrequency)?.displayName ?? "Every 2 hours"
    }

    private func resetOnboarding() {
        guard let profile = profile else { return }
        profile.onboardingCompleted = false
        try? modelContext.save()
        appState.popToRoot()
    }
}

struct SubscriptionStatusRow: View {
    @ObservedObject var subscriptionManager: SubscriptionManager

    var body: some View {
        HStack {
            Label(statusLabel, systemImage: statusIcon)
            Spacer()
            Text(statusText)
                .foregroundStyle(statusColor)
                .fontWeight(.medium)
        }
    }

    private var statusLabel: String { "Status" }

    private var statusIcon: String {
        switch subscriptionManager.currentSubscriptionStatus {
        case .subscribed: return "checkmark.seal.fill"
        case .trial: return "clock.fill"
        case .expired: return "exclamationmark.triangle.fill"
        default: return "person.fill"
        }
    }

    private var statusText: String {
        switch subscriptionManager.currentSubscriptionStatus {
        case .subscribed: return "Pro"
        case .trial: return "Trial"
        case .expired: return "Expired"
        default: return "Free"
        }
    }

    private var statusColor: Color {
        switch subscriptionManager.currentSubscriptionStatus {
        case .subscribed: return .success
        case .trial: return .streakFlame
        case .expired: return .warning
        default: return .textSecondary
        }
    }
}

// MARK: - Edit Views

struct WorkHoursEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var profile: UserProfile

    @State private var startTime: Date
    @State private var endTime: Date

    init(profile: UserProfile) {
        self.profile = profile
        _startTime = State(initialValue: profile.workStartTime)
        _endTime = State(initialValue: profile.workEndTime)
    }

    var body: some View {
        Form {
            DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
            DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
        }
        .scrollContentBackground(.hidden)
        .deskFitScreenBackground()
        .navigationTitle("Work Hours")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
            }
        }
    }

    private func save() {
        profile.workStartMinutes = startTime.minutesSinceMidnight
        profile.workEndMinutes = endTime.minutesSinceMidnight
        try? modelContext.save()
        Task {
            await NotificationService.shared.scheduleReminders(
                frequency: ReminderFrequency(rawValue: profile.reminderFrequency) ?? .every2Hours,
                workStartMinutes: profile.workStartMinutes,
                workEndMinutes: profile.workEndMinutes
            )
        }
        dismiss()
    }
}

struct ReminderFrequencyEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var profile: UserProfile

    var body: some View {
        List {
            ForEach(ReminderFrequency.allCases) { frequency in
                Button {
                    profile.reminderFrequency = frequency.rawValue
                    try? modelContext.save()
                    Task {
                        await NotificationService.shared.scheduleReminders(
                            frequency: frequency,
                            workStartMinutes: profile.workStartMinutes,
                            workEndMinutes: profile.workEndMinutes
                        )
                    }
                    dismiss()
                } label: {
                    HStack {
                        Text(frequency.displayName)
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        if profile.reminderFrequency == frequency.rawValue {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.appTeal)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .deskFitScreenBackground()
        .navigationTitle("Reminder Frequency")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FocusAreasEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var profile: UserProfile

    @State private var selectedAreas: Set<String>

    init(profile: UserProfile) {
        self.profile = profile
        _selectedAreas = State(initialValue: Set(profile.focusAreas))
    }

    var body: some View {
        List {
            ForEach(FocusArea.allCases) { area in
                Button {
                    toggleArea(area)
                } label: {
                    HStack {
                        Image(systemName: area.icon)
                            .foregroundStyle(.appTeal)
                            .frame(width: 24)
                        Text(area.displayName)
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        if selectedAreas.contains(area.rawValue) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.appTeal)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .deskFitScreenBackground()
        .navigationTitle("Focus Areas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(selectedAreas.isEmpty)
            }
        }
    }

    private func toggleArea(_ area: FocusArea) {
        if selectedAreas.contains(area.rawValue) {
            selectedAreas.remove(area.rawValue)
        } else {
            selectedAreas.insert(area.rawValue)
        }
    }

    private func save() {
        profile.focusAreas = Array(selectedAreas)
        try? modelContext.save()
        dismiss()
    }
}
