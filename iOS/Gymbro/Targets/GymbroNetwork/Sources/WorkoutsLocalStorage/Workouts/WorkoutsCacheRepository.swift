import Foundation
import GymbroTypes

public final class WorkoutsCacheRepository {
    private let dataSource: WorkoutsCacheDataSource
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(dataSource: WorkoutsCacheDataSource) {
        self.dataSource = dataSource
    }

    public func loadWorkouts(key: String) -> [Workout] {
        guard
            let data = try? dataSource.load(key: key),
            let dtos = try? decoder.decode([WorkoutDTO].self, from: data)
        else { return [] }

        return dtos.map { $0.toWorkout() }
    }

    public func loadWorkout(key: String, workoutId: String) -> Workout? {
        let workouts = loadWorkouts(key: key)
        return workouts.first { $0.id == workoutId }
    }

    public func saveWorkouts(key: String, workouts: [Workout]) {
        let dtos = workouts.map(WorkoutDTO.init(from:))
        guard let data = try? encoder.encode(dtos) else { return }
        try? dataSource.save(key: key, data: data)
    }

    public func upsertWorkout(key: String, workout: Workout) {
        var current = loadWorkouts(key: key)
        if let idx = current.firstIndex(where: { $0.id == workout.id }) {
            current[idx] = workout
        } else {
            current.append(workout)
        }
        saveWorkouts(key: key, workouts: current)
    }

    public func deleteWorkout(key: String, workoutId: String) {
        let current = loadWorkouts(key: key).filter { $0.id != workoutId }
        saveWorkouts(key: key, workouts: current)
    }

    public func clearAll() {
        try? dataSource.deleteAll()
    }
}
