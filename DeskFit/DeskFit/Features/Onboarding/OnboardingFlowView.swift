import SwiftUI
import SwiftData
import Combine

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
        Group {
            switch viewModel.currentPhase {
            case .questionnaire:
                questionnairePhase
            case .summary:
                summaryPhase
            case .starterReset:
                starterResetPhase
            case .completion:
                completionPhase
            }
        }
        .background(Color.appBackground)
        .onAppear {
            AnalyticsService.shared.track(.onboardingStarted)
            viewModel.startTime = Date()
        }
    }

    // MARK: - Questionnaire Phase (Steps 0-4)

    private var questionnairePhase: some View {
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
    }

    // MARK: - Summary Phase

    private var summaryPhase: some View {
        OnboardingSummaryView(
            goal: viewModel.selectedGoal,
            focusAreas: viewModel.selectedFocusAreas,
            dailyTimeMinutes: viewModel.selectedDailyTime,
            reminderFrequency: viewModel.reminderFrequency,
            workStartMinutes: viewModel.workStartMinutes,
            workEndMinutes: viewModel.workEndMinutes,
            onStartReset: {
                withAnimation {
                    viewModel.currentPhase = .starterReset
                }
            }
        )
    }

    // MARK: - Starter Reset Phase

    private var starterResetPhase: some View {
        StarterResetView(
            focusAreas: viewModel.selectedFocusAreas,
            onComplete: {
                // Calculate approximate duration (60s target)
                viewModel.starterResetDuration = 60
                withAnimation {
                    viewModel.currentPhase = .completion
                }
            },
            onSkip: {
                // User skipped - finalize and show paywall
                finalizeOnboarding(completedStarterReset: false)
                appState.presentPaywall(source: "post_starter_reset")
            }
        )
    }

    // MARK: - Completion Phase

    private var completionPhase: some View {
        StarterResetCompletionView(
            durationSeconds: viewModel.starterResetDuration,
            onUnlockPlans: {
                finalizeOnboarding(completedStarterReset: true)
                appState.presentPaywall(source: "post_starter_reset")
            },
            onContinueFree: {
                finalizeOnboarding(completedStarterReset: true)
            }
        )
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
            // Move to summary phase instead of completing
            withAnimation {
                viewModel.currentPhase = .summary
            }
        }
    }

    private func finalizeOnboarding(completedStarterReset: Bool) {
        guard let profile = profile else { return }

        // Save user preferences
        profile.goal = viewModel.selectedGoal?.rawValue ?? ""
        profile.focusAreas = viewModel.selectedFocusAreas.map { $0.rawValue }
        profile.dailyTimeMinutes = viewModel.selectedDailyTime
        profile.workStartMinutes = viewModel.workStartMinutes
        profile.workEndMinutes = viewModel.workEndMinutes
        profile.reminderFrequency = viewModel.reminderFrequency.rawValue
        profile.onboardingCompleted = true

        // If user completed the starter reset, initialize their streak
        if completedStarterReset {
            profile.currentStreak = 1
            profile.longestStreak = 1
            profile.lastSessionDate = Date()
            profile.totalSessions = 1
            profile.totalMinutes = 1  // 1 minute for the starter reset
        }

        try? modelContext.save()

        // Track analytics
        let duration = Int(Date().timeIntervalSince(viewModel.startTime ?? Date()))
        AnalyticsService.shared.track(.onboardingCompleted(
            durationSeconds: duration,
            goal: profile.goal,
            focusAreas: profile.focusAreas,
            dailyMinutes: profile.dailyTimeMinutes
        ))

        // Schedule notifications if enabled
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
    }
}
