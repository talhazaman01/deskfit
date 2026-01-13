import SwiftUI

struct StarterResetView: View {
    let focusAreas: Set<FocusArea>
    let stiffnessTimes: Set<StiffnessTime>
    let onComplete: () -> Void
    let onSkip: () -> Void

    @StateObject private var viewModel: StarterResetViewModel

    init(
        focusAreas: Set<FocusArea>,
        stiffnessTimes: Set<StiffnessTime> = [],
        onComplete: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.focusAreas = focusAreas
        self.stiffnessTimes = stiffnessTimes
        self.onComplete = onComplete
        self.onSkip = onSkip
        _viewModel = StateObject(wrappedValue: StarterResetViewModel(
            focusAreas: Array(focusAreas),
            stiffnessTimes: stiffnessTimes
        ))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isComplete {
                completedState
            } else if viewModel.isReady {
                // Ready state - waiting for user to press Play
                readyState
            } else if viewModel.isPaused {
                pausedState
            } else {
                activeState
            }
        }
        .onAppear {
            // Track that user viewed the starter reset screen (does NOT auto-start)
            AnalyticsService.shared.track(.starterResetViewed)
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: - Ready State

    private var readyState: some View {
        VStack(spacing: Theme.Spacing.md) {
            // MARK: - Top Section
            VStack(spacing: Theme.Spacing.sm) {
                // Top bar with skip
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

                    Text(viewModel.sessionTitle)
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

                Text("\(viewModel.exercises.count) exercises • ~1 min")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }

            // MARK: - Exercise Preview
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

            // MARK: - Timer (Static) and Play Button
            VStack(spacing: Theme.Spacing.lg) {
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
                .accessibilityLabel("Start starter reset")
            }
            .padding(.bottom, Theme.Spacing.xl)
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

                    Text(viewModel.sessionTitle)
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

            // MARK: - Bottom Section (Fixed - Timer & Play/Pause)
            VStack(spacing: Theme.Spacing.lg) {
                TimerView(
                    timeRemaining: viewModel.timeRemaining,
                    totalTime: viewModel.currentExercise?.durationSeconds ?? 0
                )

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
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            // Brief success indicator before transitioning
            ZStack {
                Circle()
                    .fill(Color.success.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.success)
            }

            Text("Great job!")
                .font(Theme.Typography.title)
                .foregroundStyle(.textPrimary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .onAppear {
            HapticsService.shared.sessionComplete()
            // Small delay to show the success state before transitioning
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
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
        focusAreas: [.neck, .shoulders, .upperBack],
        onComplete: {},
        onSkip: {}
    )
}

#Preview("iPhone 15 Pro") {
    StarterResetView(
        focusAreas: [.neck, .shoulders, .upperBack],
        onComplete: {},
        onSkip: {}
    )
}

#Preview("iPhone 15 Pro Max") {
    StarterResetView(
        focusAreas: [.neck, .shoulders, .upperBack],
        onComplete: {},
        onSkip: {}
    )
}
