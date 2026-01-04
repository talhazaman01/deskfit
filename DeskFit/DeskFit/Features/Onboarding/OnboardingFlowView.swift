import SwiftUI
import SwiftData
import Combine

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var profiles: [UserProfile]

    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep = 0

    // Updated to 10 steps: goal, focus, stiffness, dob, gender, height/weight, time, work hours, reminders, airpods
    private let totalSteps = 10

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
            case .safety:
                safetyPhase
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
                // Step 0: Goal
                GoalSelectionView(selectedGoal: $viewModel.selectedGoal)
                    .tag(0)

                // Step 1: Focus Areas
                FocusAreasView(selectedAreas: $viewModel.selectedFocusAreas)
                    .tag(1)

                // Step 2: Stiffness Times (when stiffness hits) - multi-select
                StiffnessTimeView(selectedStiffnessTimes: $viewModel.selectedStiffnessTimes)
                    .tag(2)

                // Step 3: Date of Birth
                DateOfBirthView(
                    dateOfBirth: $viewModel.dateOfBirth,
                    hasSetDateOfBirth: $viewModel.hasSetDateOfBirth
                )
                    .tag(3)

                // Step 4: Gender
                GenderSelectionView(selectedGender: $viewModel.selectedGender)
                    .tag(4)

                // Step 5: Height & Weight
                HeightWeightView(
                    measurementUnit: $viewModel.measurementUnit,
                    heightFeet: $viewModel.heightFeet,
                    heightInches: $viewModel.heightInches,
                    heightCm: $viewModel.heightCm,
                    weightLb: $viewModel.weightLb,
                    weightKg: $viewModel.weightKg,
                    hasEnteredHeight: $viewModel.hasEnteredHeight,
                    hasEnteredWeight: $viewModel.hasEnteredWeight
                )
                    .tag(5)

                // Step 6: Time Preference
                TimePreferenceView(selectedTime: $viewModel.selectedDailyTime)
                    .tag(6)

                // Step 7: Work Hours
                WorkHoursView(
                    startMinutes: $viewModel.workStartMinutes,
                    endMinutes: $viewModel.workEndMinutes,
                    sedentaryHoursBucket: $viewModel.sedentaryHoursBucket
                )
                    .tag(7)

                // Step 8: Reminders
                ReminderSetupView(selectedFrequency: $viewModel.reminderFrequency)
                    .tag(8)

                // Step 9: AirPods
                AirPodsOnboardingStepView(selectedResponse: $viewModel.airpodsResponse)
                    .tag(9)
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
            hasPersonalInfo: viewModel.hasSetDateOfBirth || viewModel.selectedGender != nil || viewModel.hasEnteredHeight || viewModel.hasEnteredWeight,
            onStartReset: {
                withAnimation {
                    viewModel.currentPhase = .safety
                }
            }
        )
    }

    // MARK: - Safety Phase

    private var safetyPhase: some View {
        SafetyAcknowledgmentView(
            onContinue: {
                withAnimation {
                    viewModel.currentPhase = .starterReset
                }
            },
            onSkip: {
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
            stiffnessTimes: viewModel.selectedStiffnessTimes,
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
        case 0: // Goal
            return viewModel.selectedGoal != nil
        case 1: // Focus Areas
            return !viewModel.selectedFocusAreas.isEmpty
        case 2: // Stiffness Times - at least one must be selected
            return !viewModel.selectedStiffnessTimes.isEmpty
        case 3: // DOB - must be 13+ years old
            return viewModel.isDateOfBirthValid
        case 4: // Gender - always valid (optional, can continue without selection)
            return true
        case 5: // Height/Weight - always valid (optional) but validate ranges if entered
            return viewModel.isHeightValid && viewModel.isWeightValid
        case 6: // Time Preference
            return true
        case 7: // Work Hours
            return viewModel.workEndMinutes > viewModel.workStartMinutes
        case 8: // Reminders
            return true
        case 9: // AirPods - always valid (can skip with "Not sure" or just continue)
            return viewModel.airpodsResponse != nil
        default:
            return false
        }
    }

    // MARK: - Actions

    private func handleContinue() {
        let stepNames = ["goal", "focus_areas", "stiffness_time", "dob", "gender", "height_weight", "time", "work_hours", "reminders", "airpods"]
        AnalyticsService.shared.track(.onboardingStepCompleted(step: stepNames[currentStep]))

        // Track additional properties for personalization steps
        trackPersonalizationStep()

        if currentStep < totalSteps - 1 {
            withAnimation { currentStep += 1 }
        } else {
            // Move to summary phase instead of completing
            withAnimation {
                viewModel.currentPhase = .summary
            }
        }
    }

    private func trackPersonalizationStep() {
        switch currentStep {
        case 2: // Stiffness Times
            let stiffnessTimeValue = viewModel.stiffnessTimesAnalyticsValue
            AnalyticsService.shared.track(.onboardingStiffnessTime(stiffnessTime: stiffnessTimeValue))
        case 3: // DOB
            let ageBand = AgeBand.from(age: viewModel.age)
            AnalyticsService.shared.track(.onboardingPersonalInfo(
                step: "dob",
                ageBand: ageBand.rawValue,
                gender: nil,
                hasHeight: nil,
                hasWeight: nil
            ))
        case 4: // Gender
            let genderValue = viewModel.selectedGender != .preferNotToSay ? viewModel.selectedGender?.rawValue : nil
            AnalyticsService.shared.track(.onboardingPersonalInfo(
                step: "gender",
                ageBand: nil,
                gender: genderValue,
                hasHeight: nil,
                hasWeight: nil
            ))
        case 5: // Height/Weight
            AnalyticsService.shared.track(.onboardingPersonalInfo(
                step: "height_weight",
                ageBand: nil,
                gender: nil,
                hasHeight: viewModel.hasEnteredHeight,
                hasWeight: viewModel.hasEnteredWeight
            ))
        case 7: // Work Hours
            AnalyticsService.shared.track(.onboardingWorkHours(
                sedentaryHoursBucket: viewModel.sedentaryHoursBucket?.rawValue
            ))
        case 9: // AirPods
            if let response = viewModel.airpodsResponse {
                AnalyticsService.shared.track(.onboardingAirpodsAnswered(
                    value: response.rawValue,
                    detectedNow: AirPodsDetectionService.shared.isHeadphoneDetected
                ))
            }
        default:
            break
        }
    }

    private func finalizeOnboarding(completedStarterReset: Bool) {
        guard let profile = profile else { return }

        // Save core preferences
        profile.goal = viewModel.selectedGoal?.rawValue ?? ""
        profile.focusAreas = viewModel.selectedFocusAreas.map { $0.rawValue }
        profile.dailyTimeMinutes = viewModel.selectedDailyTime
        profile.workStartMinutes = viewModel.workStartMinutes
        profile.workEndMinutes = viewModel.workEndMinutes
        profile.reminderFrequency = viewModel.reminderFrequency.rawValue
        profile.stiffnessTimes = viewModel.selectedStiffnessTimes.map { $0.rawValue }.sorted()
        profile.sedentaryHoursBucket = viewModel.sedentaryHoursBucket?.rawValue

        // Save personal info (for personalization)
        if viewModel.hasSetDateOfBirth {
            profile.dateOfBirth = viewModel.dateOfBirth
        }
        if let gender = viewModel.selectedGender {
            profile.gender = gender.rawValue
        }
        profile.heightCm = viewModel.heightCmForStorage
        profile.weightKg = viewModel.weightKgForStorage

        profile.onboardingCompleted = true

        // Save AirPods response to the capability store
        if let airpodsResponse = viewModel.airpodsResponse {
            AirPodsCapabilityStore.shared.setOnboardingResponse(airpodsResponse)
        }

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
            dailyMinutes: profile.dailyTimeMinutes,
            stiffnessTime: viewModel.stiffnessTimesAnalyticsValue
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
