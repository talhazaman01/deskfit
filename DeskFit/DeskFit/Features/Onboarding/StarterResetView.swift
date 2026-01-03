import SwiftUI

struct StarterResetView: View {
    let focusAreas: Set<FocusArea>
    let onComplete: () -> Void
    let onSkip: () -> Void

    @StateObject private var viewModel: StarterResetViewModel

    init(
        focusAreas: Set<FocusArea>,
        onComplete: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.focusAreas = focusAreas
        self.onComplete = onComplete
        self.onSkip = onSkip
        _viewModel = StateObject(wrappedValue: StarterResetViewModel(focusAreas: Array(focusAreas)))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isComplete {
                completedState
            } else if viewModel.isPaused {
                pausedState
            } else {
                activeState
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: - Active State

    private var activeState: some View {
        VStack(spacing: Theme.Spacing.xxl) {
            // Top bar with skip and progress
            HStack {
                Button {
                    viewModel.stop()
                    AnalyticsService.shared.track(.starterResetSkipped)
                    onSkip()
                } label: {
                    Text("Skip")
                        .font(Theme.Typography.subtitle)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()

                Text("Starter Reset")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Spacer()

                // Invisible button for balance
                Text("Skip")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.clear)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, Theme.Spacing.md)

            // Progress bar
            ProgressView(value: viewModel.overallProgress)
                .tint(.appTeal)
                .padding(.horizontal, Theme.Spacing.screenHorizontal)

            Text("\(viewModel.currentExerciseIndex + 1) of \(viewModel.exercises.count)")
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)

            Spacer()

            // Exercise display
            if let exercise = viewModel.currentExercise {
                exerciseDisplay(exercise)
            }

            Spacer()

            // Timer
            TimerView(
                timeRemaining: viewModel.timeRemaining,
                totalTime: viewModel.currentExercise?.durationSeconds ?? 0
            )

            // Pause button
            Button {
                viewModel.pause()
            } label: {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.appTeal)
            }
            .padding(.bottom, Theme.Spacing.xxl)
        }
    }

    private func exerciseDisplay(_ exercise: Exercise) -> some View {
        VStack(spacing: Theme.Spacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.appTeal.opacity(0.1))
                    .frame(width: 180, height: 180)

                Image(systemName: "figure.flexibility")
                    .font(.system(size: 70))
                    .foregroundStyle(.appTeal)
            }

            Text(exercise.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)

            Text(exercise.cue)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
        }
    }

    // MARK: - Paused State

    private var pausedState: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Text("Paused")
                .font(Theme.Typography.title)
                .foregroundStyle(.textPrimary)

            PrimaryButton(title: "Resume") {
                viewModel.resume()
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            SecondaryButton(title: "Skip to finish", style: .text) {
                viewModel.stop()
                AnalyticsService.shared.track(.starterResetSkipped)
                onSkip()
            }
        }
    }

    // MARK: - Completed State

    private var completedState: some View {
        VStack {
            // Trigger completion callback
            Color.clear
                .onAppear {
                    HapticsService.shared.sessionComplete()
                    onComplete()
                }
        }
    }
}

#Preview {
    StarterResetView(
        focusAreas: [.neck, .shoulders],
        onComplete: {},
        onSkip: {}
    )
}
