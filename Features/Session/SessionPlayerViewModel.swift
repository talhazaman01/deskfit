import Foundation
import Combine

@MainActor
class SessionPlayerViewModel: ObservableObject {
    let session: PlannedSession
    let exercises: [Exercise]

    @Published var currentExerciseIndex = 0
    @Published var timeRemaining: Int = 0
    @Published var isPaused = false
    @Published var isComplete = false

    private var timer: Timer?
    private var pauseStartTime: Date?

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
    }

    func start() {
        guard !exercises.isEmpty else {
            isComplete = true
            return
        }

        timeRemaining = exercises[0].durationSeconds
        HapticsService.shared.exerciseStart()
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func pause() {
        isPaused = true
        pauseStartTime = Date()
        timer?.invalidate()

        AnalyticsService.shared.track(.sessionPaused(
            sessionId: session.id.uuidString,
            elapsedSeconds: calculateElapsedSeconds()
        ))
    }

    func resume() {
        if let pauseStart = pauseStartTime {
            let pauseDuration = Int(Date().timeIntervalSince(pauseStart))
            AnalyticsService.shared.track(.sessionResumed(
                sessionId: session.id.uuidString,
                pauseDurationSeconds: pauseDuration
            ))
        }

        isPaused = false
        pauseStartTime = nil
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard !isPaused else { return }

        timeRemaining -= 1

        if timeRemaining == 5 {
            HapticsService.shared.fiveSecondsLeft()
        }

        if timeRemaining <= 0 {
            completeCurrentExercise()
        }
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
            isComplete = true
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
