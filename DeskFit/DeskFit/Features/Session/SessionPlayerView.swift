import SwiftUI
import SwiftData
import Combine

struct SessionPlayerView: View {
    let plannedSession: PlannedSession
    let sourceTab: String
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var profiles: [UserProfile]
    @Query private var weeklyPlans: [WeeklyPlan]

    @StateObject private var viewModel: SessionPlayerViewModel

    private var profile: UserProfile? {
        profiles.first
    }

    private var currentWeeklyPlan: WeeklyPlan? {
        weeklyPlans.first { plan in
            let calendar = Calendar.current
            let weekStart = plan.weekStartDate
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            return Date() >= weekStart && Date() <= weekEnd
        }
    }

    init(plannedSession: PlannedSession, sourceTab: String, onDismiss: @escaping () -> Void) {
        self.plannedSession = plannedSession
        self.sourceTab = sourceTab
        self.onDismiss = onDismiss
        _viewModel = StateObject(wrappedValue: SessionPlayerViewModel(session: plannedSession))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isComplete {
                SessionCompleteView(
                    session: plannedSession,
                    onFeedback: { feedback in
                        handleSessionComplete(feedback: feedback)
                    }
                )
            } else if viewModel.isReady {
                // Ready state - waiting for user to press Play
                readyStateView
            } else if viewModel.isPaused {
                VStack(spacing: Theme.Spacing.xl) {
                    Text("Paused")
                        .font(Theme.Typography.title)
                        .foregroundStyle(.textPrimary)

                    PrimaryButton(title: "Resume") {
                        viewModel.resume()
                    }

                    SecondaryButton(title: "End Session") {
                        handleAbandon()
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
            } else {
                VStack(spacing: Theme.Spacing.md) {
                    // MARK: - Top Section (Fixed)
                    VStack(spacing: Theme.Spacing.sm) {
                        ProgressView(value: viewModel.overallProgress)
                            .tint(.appTeal)
                            .padding(.horizontal, Theme.Spacing.screenHorizontal)

                        Text("\(viewModel.currentExerciseIndex + 1) of \(viewModel.exercises.count)")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textSecondary)
                    }

                    // MARK: - Scrollable Content Area
                    // Scrolls only when content exceeds available space
                    ScrollView(.vertical, showsIndicators: false) {
                        if let exercise = viewModel.currentExercise {
                            ExerciseDisplayView(
                                exercise: exercise,
                                timeRemaining: viewModel.timeRemaining
                            )
                            .padding(.vertical, Theme.Spacing.md)
                        }
                    }
                    .frame(maxHeight: .infinity)

                    // MARK: - Bottom Section (Fixed - Timer, Controls)
                    VStack(spacing: Theme.Spacing.lg) {
                        TimerView(
                            timeRemaining: viewModel.timeRemaining,
                            totalTime: viewModel.currentExercise?.durationSeconds ?? 0
                        )

                        // Control buttons: Play/Pause and Next
                        HStack(spacing: Theme.Spacing.xl) {
                            // Play/Pause toggle button
                            Button {
                                if viewModel.isPlaying {
                                    viewModel.pause()
                                } else {
                                    viewModel.start()
                                }
                            } label: {
                                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.appTeal)
                            }
                            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")

                            // Next/Finish button
                            Button {
                                viewModel.skipToNext()
                            } label: {
                                VStack(spacing: Theme.Spacing.xs) {
                                    Image(systemName: viewModel.isLastExercise ? "checkmark.circle.fill" : "forward.fill")
                                        .font(.system(size: 32))
                                    Text(viewModel.isLastExercise ? "Finish" : "Next")
                                        .font(Theme.Typography.caption)
                                }
                                .foregroundStyle(.textSecondary)
                            }
                            .accessibilityLabel(viewModel.isLastExercise ? "Finish session" : "Skip to next exercise")
                        }
                    }
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if viewModel.isComplete {
                        onDismiss()
                    } else {
                        viewModel.pause()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .onAppear {
            // Track that user viewed the session screen (does NOT auto-start)
            AnalyticsService.shared.track(.sessionViewed(
                sessionId: plannedSession.id.uuidString,
                sessionType: plannedSession.type.rawValue,
                source: sourceTab
            ))
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: - Ready State View

    private var readyStateView: some View {
        VStack(spacing: Theme.Spacing.md) {
            // MARK: - Top Section
            VStack(spacing: Theme.Spacing.sm) {
                Text(plannedSession.title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Text("\(viewModel.exercises.count) exercises • \(plannedSession.durationSeconds / 60) min")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.top, Theme.Spacing.xl)

            // MARK: - Exercise Preview
            ScrollView(.vertical, showsIndicators: false) {
                if let exercise = viewModel.currentExercise {
                    ExerciseDisplayView(
                        exercise: exercise,
                        timeRemaining: viewModel.timeRemaining
                    )
                    .padding(.vertical, Theme.Spacing.md)
                }
            }
            .frame(maxHeight: .infinity)

            // MARK: - Timer (Static) and Play Button
            VStack(spacing: Theme.Spacing.lg) {
                // Static timer showing initial time
                TimerView(
                    timeRemaining: viewModel.timeRemaining,
                    totalTime: viewModel.currentExercise?.durationSeconds ?? 0
                )

                Text("Ready")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)

                // Play button
                Button {
                    viewModel.start()
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.appTeal)
                }
                .accessibilityLabel("Start session")
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
    }

    private func handleSessionComplete(feedback: SessionFeedback?) {
        guard let profile = profile else {
            onDismiss()
            return
        }

        UserProfileManager.shared.recordSessionComplete(
            profile: profile,
            session: plannedSession,
            feedback: feedback?.rawValue,
            context: modelContext
        )

        // Mark session completed in weekly plan
        if let weeklyPlan = currentWeeklyPlan {
            PlanGeneratorService.shared.markSessionCompletedInWeeklyPlan(
                session: plannedSession,
                in: weeklyPlan,
                context: modelContext
            )
        }

        // Record to ProgressStore for Progress tab tracking
        // IMPORTANT: Do this synchronously BEFORE dismissing to ensure Progress tab updates
        let snapshot = OnboardingProfileSnapshot.from(profile: profile)
        let exercises = ExerciseService.shared.getAllExercises()
        let sessionExercises = plannedSession.exerciseIds.compactMap { id in
            exercises.first(where: { $0.id == id })
        }
        let focusAreas = Array(Set(sessionExercises.flatMap { $0.focusAreas }))

        ProgressStore.shared.recordSessionCompletion(
            durationSeconds: plannedSession.durationSeconds,
            focusAreas: focusAreas,
            profile: snapshot,
            currentStreak: profile.currentStreak
        )

        AnalyticsService.shared.track(.sessionCompleted(
            sessionId: plannedSession.id.uuidString,
            durationSeconds: plannedSession.durationSeconds,
            feedback: feedback?.rawValue
        ))

        HapticsService.shared.sessionComplete()

        onDismiss()
    }

    private func handleAbandon() {
        AnalyticsService.shared.track(.sessionAbandoned(
            sessionId: plannedSession.id.uuidString,
            completedExercises: viewModel.currentExerciseIndex,
            totalExercises: viewModel.exercises.count
        ))
        onDismiss()
    }
}
