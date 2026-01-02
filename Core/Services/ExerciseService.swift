import Foundation

class ExerciseService {
    static let shared = ExerciseService()

    private var exercises: [Exercise] = []

    private init() {
        loadExercises()
    }

    private func loadExercises() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let library = try? JSONDecoder().decode(ExerciseLibrary.self, from: data) else {
            print("Failed to load exercises.json")
            return
        }
        exercises = library.exercises
    }

    func getAllExercises() -> [Exercise] {
        exercises
    }

    func getExercise(by id: String) -> Exercise? {
        exercises.first { $0.id == id }
    }

    func getExercises(for focusAreas: [String]) -> [Exercise] {
        exercises.filter { exercise in
            !Set(exercise.focusAreas).isDisjoint(with: Set(focusAreas))
        }
    }

    func getExercises(ids: [String]) -> [Exercise] {
        ids.compactMap { id in
            exercises.first { $0.id == id }
        }
    }

    func getExercises(forDuration targetSeconds: Int, focusAreas: [String]) -> [Exercise] {
        let filtered = getExercises(for: focusAreas).shuffled()
        var selected: [Exercise] = []
        var totalDuration = 0

        for exercise in filtered {
            if totalDuration + exercise.durationSeconds <= targetSeconds {
                selected.append(exercise)
                totalDuration += exercise.durationSeconds
            }
            if totalDuration >= targetSeconds - 10 {
                break
            }
        }

        return selected
    }
}
