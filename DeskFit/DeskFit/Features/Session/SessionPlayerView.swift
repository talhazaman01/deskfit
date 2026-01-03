import SwiftUI
import SwiftData
import Combine

struct SessionPlayerView: View {
    let plannedSession: PlannedSession

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyPlan.date, order: .reverse) private var plans: [DailyPlan]

    @StateObject private var viewModel: SessionPlayerViewModel

    private var profile: UserProfile? {
        profiles.first
    }

    private var todaysPlan: DailyPlan? {
        plans.first { Calendar.current.isDateInToday($0.date) }
    }

    init(plannedSession: PlannedSession) {
        self.plannedSession = plannedSession
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

                    // MARK: - Bottom Section (Fixed - Timer & Pause)
                    VStack(spacing: Theme.Spacing.lg) {
                        TimerView(
                            timeRemaining: viewModel.timeRemaining,
                            totalTime: viewModel.currentExercise?.durationSeconds ?? 0
                        )

                        Button {
                            viewModel.pause()
                        } label: {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.appTeal)
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
                        dismiss()
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
            viewModel.start()
            AnalyticsService.shared.track(.sessionStarted(
                sessionId: plannedSession.id.uuidString,
                sessionType: plannedSession.type.rawValue,
                durationSeconds: plannedSession.durationSeconds,
                exerciseCount: plannedSession.exerciseIds.count
            ))
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private func handleSessionComplete(feedback: SessionFeedback?) {
        guard let profile = profile, let plan = todaysPlan else {
            dismiss()
            return
        }

        UserProfileManager.shared.recordSessionComplete(
            profile: profile,
            session: plannedSession,
            feedback: feedback?.rawValue,
            context: modelContext
        )

        PlanGeneratorService.shared.markSessionCompleted(
            session: plannedSession,
            in: plan,
            context: modelContext
        )

        AnalyticsService.shared.track(.sessionCompleted(
            sessionId: plannedSession.id.uuidString,
            durationSeconds: plannedSession.durationSeconds,
            feedback: feedback?.rawValue
        ))

        HapticsService.shared.sessionComplete()

        appState.popToRoot()
    }

    private func handleAbandon() {
        AnalyticsService.shared.track(.sessionAbandoned(
            sessionId: plannedSession.id.uuidString,
            completedExercises: viewModel.currentExerciseIndex,
            totalExercises: viewModel.exercises.count
        ))
        dismiss()
    }
}
