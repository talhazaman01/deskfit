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
        VStack(spacing: Theme.Spacing.md) {
            // MARK: - Top Section (Fixed)
            VStack(spacing: Theme.Spacing.sm) {
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
            }

            // MARK: - Scrollable Content Area
            // Uses shared component with full text display (no truncation)
            // Scrolls only when content exceeds available space
            ScrollView(.vertical, showsIndicators: false) {
                if let exercise = viewModel.currentExercise {
                    SessionExerciseContentView(
                        exercise: exercise,
                        isCompact: true
                    )
                    .padding(.vertical, Theme.Spacing.sm)
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

#Preview("Default") {
    StarterResetView(
        focusAreas: [.neck, .shoulders],
        onComplete: {},
        onSkip: {}
    )
}

#Preview("iPhone SE") {
    StarterResetView(
        focusAreas: [.neck, .shoulders, .back],
        onComplete: {},
        onSkip: {}
    )
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("iPhone 15 Pro") {
    StarterResetView(
        focusAreas: [.neck, .shoulders, .back],
        onComplete: {},
        onSkip: {}
    )
    .previewDevice("iPhone 15 Pro")
}

#Preview("iPhone 15 Pro Max") {
    StarterResetView(
        focusAreas: [.neck, .shoulders, .back],
        onComplete: {},
        onSkip: {}
    )
    .previewDevice("iPhone 15 Pro Max")
}
