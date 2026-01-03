import Foundation
import Combine

@MainActor
class StarterResetViewModel: ObservableObject {
    let exercises: [Exercise]
    let sessionTitle: String
    let targetDurationSeconds: Int = 60

    @Published var currentExerciseIndex = 0
    @Published var timeRemaining: Int = 0
    @Published var isPaused = false
    @Published var isComplete = false

    private var timer: Timer?
    private var startTime: Date?

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

    var totalDurationSeconds: Int {
        exercises.reduce(0) { $0 + $1.durationSeconds }
    }

    init(focusAreas: [FocusArea], stiffnessTime: StiffnessTime? = nil) {
        // Generate tailored starter reset using PlanGeneratorService
        let starterReset = PlanGeneratorService.shared.generateStarterReset(
            focusAreas: Set(focusAreas),
            stiffnessTime: stiffnessTime,
            targetDuration: 60
        )
        self.sessionTitle = starterReset.title
        self.exercises = starterReset.exercises
    }

    private static func selectExercises(
        forDuration targetSeconds: Int,
        focusAreas: [String],
        maxExercises: Int
    ) -> [Exercise] {
        let allExercises = ExerciseService.shared.getExercises(for: focusAreas)
        guard !allExercises.isEmpty else {
            return Array(ExerciseService.shared.getAllExercises().shuffled().prefix(maxExercises))
        }

        let shuffled = allExercises.shuffled()
        var selected: [Exercise] = []
        var totalDuration = 0

        for exercise in shuffled {
            if selected.count >= maxExercises {
                break
            }
            if totalDuration + exercise.durationSeconds <= targetSeconds + 15 {
                selected.append(exercise)
                totalDuration += exercise.durationSeconds
            }
            if totalDuration >= targetSeconds - 10 {
                break
            }
        }

        if selected.isEmpty, let first = shuffled.first {
            selected.append(first)
        }

        return selected
    }

    func start() {
        guard !exercises.isEmpty else {
            isComplete = true
            return
        }

        startTime = Date()
        timeRemaining = exercises[0].durationSeconds
        HapticsService.shared.exerciseStart()
        startTimer()

        AnalyticsService.shared.track(.starterResetStarted)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func pause() {
        isPaused = true
        timer?.invalidate()
    }

    func resume() {
        isPaused = false
        startTimer()
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
            trackCompletion()
        } else {
            timeRemaining = exercises[currentExerciseIndex].durationSeconds
            HapticsService.shared.exerciseStart()
        }
    }

    private func trackCompletion() {
        AnalyticsService.shared.track(.starterResetCompleted(
            durationSeconds: totalDurationSeconds,
            exerciseCount: exercises.count
        ))
    }
}
