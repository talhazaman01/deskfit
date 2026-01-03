import SwiftUI
import SwiftData

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var profiles: [UserProfile]

    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep = 0

    private let totalSteps = 5

    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar with back and progress
            navigationBar

            // Content
            TabView(selection: $currentStep) {
                GoalSelectionView(selectedGoal: $viewModel.selectedGoal)
                    .tag(0)

                FocusAreasView(selectedAreas: $viewModel.selectedFocusAreas)
                    .tag(1)

                TimePreferenceView(selectedTime: $viewModel.selectedDailyTime)
                    .tag(2)

                WorkHoursView(
                    startMinutes: $viewModel.workStartMinutes,
                    endMinutes: $viewModel.workEndMinutes
                )
                    .tag(3)

                ReminderSetupView(selectedFrequency: $viewModel.reminderFrequency)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentStep)

            // Bottom button area
            bottomArea
        }
        .background(Color.appBackground)
        .onAppear {
            AnalyticsService.shared.track(.onboardingStarted)
            viewModel.startTime = Date()
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Back button
            Button {
                if currentStep > 0 {
                    withAnimation { currentStep -= 1 }
                }
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(currentStep > 0 ? .textPrimary : .clear)
            }
            .disabled(currentStep == 0)

            // Progress bar
            ProgressBar(progress: Double(currentStep + 1) / Double(totalSteps))
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.lg)
    }

    // MARK: - Bottom Area

    private var bottomArea: some View {
        PrimaryButton(
            title: currentStep == totalSteps - 1 ? "Get Started" : "Continue",
            isEnabled: isCurrentStepValid
        ) {
            handleContinue()
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.bottom, Theme.Spacing.bottomArea)
    }

    // MARK: - Validation

    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: return viewModel.selectedGoal != nil
        case 1: return !viewModel.selectedFocusAreas.isEmpty
        case 2: return true
        case 3: return viewModel.workEndMinutes > viewModel.workStartMinutes
        case 4: return true
        default: return false
        }
    }

    // MARK: - Actions

    private func handleContinue() {
        let stepNames = ["goal", "focus_areas", "time", "work_hours", "reminders"]
        AnalyticsService.shared.track(.onboardingStepCompleted(step: stepNames[currentStep]))

        if currentStep < totalSteps - 1 {
            withAnimation { currentStep += 1 }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        guard let profile = profile else { return }

        profile.goal = viewModel.selectedGoal?.rawValue ?? ""
        profile.focusAreas = viewModel.selectedFocusAreas.map { $0.rawValue }
        profile.dailyTimeMinutes = viewModel.selectedDailyTime
        profile.workStartMinutes = viewModel.workStartMinutes
        profile.workEndMinutes = viewModel.workEndMinutes
        profile.reminderFrequency = viewModel.reminderFrequency.rawValue
        profile.onboardingCompleted = true

        try? modelContext.save()

        let duration = Int(Date().timeIntervalSince(viewModel.startTime ?? Date()))
        AnalyticsService.shared.track(.onboardingCompleted(
            durationSeconds: duration,
            goal: profile.goal,
            focusAreas: profile.focusAreas,
            dailyMinutes: profile.dailyTimeMinutes
        ))

        if viewModel.reminderFrequency != .off {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                if granted {
                    await NotificationService.shared.scheduleReminders(
                        frequency: viewModel.reminderFrequency,
                        workStartMinutes: viewModel.workStartMinutes,
                        workEndMinutes: viewModel.workEndMinutes
                    )
                }
                profile.notificationPermissionAsked = true
                try? modelContext.save()
            }
        }

        appState.presentPaywall(source: "onboarding")
    }
}
