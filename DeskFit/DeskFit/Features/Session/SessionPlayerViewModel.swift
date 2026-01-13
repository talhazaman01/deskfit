import Foundation
import Combine

/// Playback state machine for session lifecycle
enum PlaybackState: Equatable {
    case ready      // Session loaded but not started - waiting for user to press Play
    case playing    // Timer actively counting down
    case paused     // User paused the session
    case finished   // All exercises completed
}

@MainActor
class SessionPlayerViewModel: ObservableObject {
    let session: PlannedSession
    let exercises: [Exercise]

    @Published var currentExerciseIndex = 0
    @Published var timeRemaining: Int = 0
    @Published private(set) var playbackState: PlaybackState = .ready

    /// Tracks whether session_started event has been fired (only fires once per session)
    private var hasFiredSessionStartedEvent = false

    private var timer: Timer?
    private var pauseStartTime: Date?

    // MARK: - Computed Properties for backward compatibility

    var isPaused: Bool {
        playbackState == .paused
    }

    var isComplete: Bool {
        playbackState == .finished
    }

    var isReady: Bool {
        playbackState == .ready
    }

    var isPlaying: Bool {
        playbackState == .playing
    }

    var currentExercise: Exercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }

    var overallProgress: Double {
        guard !exercises.isEmpty else { return 0 }

        let completedDuration = exercises.prefix(currentExerciseIndex)
            .reduce(0) { $0 + $1.durationSeconds }
        let currentProgress = (currentExercise?.durationSeconds ?? 0) - timeRemaining
        let totalDuration = exercises.reduce(0) { $0 + $1.durationSeconds }

        return Double(completedDuration + currentProgress) / Double(totalDuration)
    }

    init(session: PlannedSession) {
        self.session = session
        self.exercises = ExerciseService.shared.getExercises(ids: session.exerciseIds)
        // Pre-load first exercise duration so UI shows correct time in ready state
        if let firstExercise = exercises.first {
            self.timeRemaining = firstExercise.durationSeconds
        }
    }

    /// Called when user taps Play button. Transitions from ready/paused to playing.
    func start() {
        guard !exercises.isEmpty else {
            playbackState = .finished
            return
        }

        // Only transition from ready or paused states
        guard playbackState == .ready || playbackState == .paused else { return }

        // Fire session_started analytics only on first play
        if !hasFiredSessionStartedEvent {
            hasFiredSessionStartedEvent = true
            AnalyticsService.shared.track(.sessionStarted(
                sessionId: session.id.uuidString,
                sessionType: session.type.rawValue,
                durationSeconds: session.durationSeconds,
                exerciseCount: session.exerciseIds.count
            ))
        }

        // If resuming from pause, track it
        if playbackState == .paused, let pauseStart = pauseStartTime {
            let pauseDuration = Int(Date().timeIntervalSince(pauseStart))
            AnalyticsService.shared.track(.sessionResumed(
                sessionId: session.id.uuidString,
                pauseDurationSeconds: pauseDuration
            ))
            pauseStartTime = nil
        }

        playbackState = .playing
        HapticsService.shared.exerciseStart()
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func pause() {
        guard playbackState == .playing else { return }

        playbackState = .paused
        pauseStartTime = Date()
        timer?.invalidate()
        timer = nil

        AnalyticsService.shared.track(.sessionPaused(
            sessionId: session.id.uuidString,
            elapsedSeconds: calculateElapsedSeconds()
        ))
    }

    /// Resume is now handled by start() - keeping for API compatibility
    func resume() {
        start()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        // Only tick when actively playing
        guard playbackState == .playing else { return }

        timeRemaining -= 1

        if timeRemaining == 5 {
            HapticsService.shared.fiveSecondsLeft()
        }

        if timeRemaining <= 0 {
            completeCurrentExercise()
        }
    }

    /// Skip to the next exercise early. Safe to call even if timer is running.
    func skipToNext() {
        guard let exercise = currentExercise else { return }

        // Stop current timer first to avoid double-tick race
        timer?.invalidate()
        timer = nil

        // Track skip event
        let skippedAtSeconds = exercise.durationSeconds - timeRemaining
        AnalyticsService.shared.track(.exerciseSkipped(
            exerciseId: exercise.id,
            skippedAtSeconds: skippedAtSeconds,
            totalDurationSeconds: exercise.durationSeconds
        ))

        HapticsService.shared.exerciseComplete()

        currentExerciseIndex += 1

        if currentExerciseIndex >= exercises.count {
            playbackState = .finished
        } else {
            timeRemaining = exercises[currentExerciseIndex].durationSeconds
            HapticsService.shared.exerciseStart()
            // Only restart timer if we were playing
            if playbackState == .playing {
                startTimer()
            }
        }
    }

    /// Returns true if on the last exercise
    var isLastExercise: Bool {
        currentExerciseIndex >= exercises.count - 1
    }

    private func completeCurrentExercise() {
        guard let exercise = currentExercise else { return }

        HapticsService.shared.exerciseComplete()

        AnalyticsService.shared.track(.exerciseCompleted(
            exerciseId: exercise.id,
            durationSeconds: exercise.durationSeconds
        ))

        currentExerciseIndex += 1

        if currentExerciseIndex >= exercises.count {
            timer?.invalidate()
            timer = nil
            playbackState = .finished
        } else {
            timeRemaining = exercises[currentExerciseIndex].durationSeconds
            HapticsService.shared.exerciseStart()
        }
    }

    private func calculateElapsedSeconds() -> Int {
        let completedDuration = exercises.prefix(currentExerciseIndex)
            .reduce(0) { $0 + $1.durationSeconds }
        let currentProgress = (currentExercise?.durationSeconds ?? 0) - timeRemaining
        return completedDuration + currentProgress
    }
}
