import Foundation

import GymbroTypes
import GymbroNetwork

protocol WorkoutPlayerService {
    func fetchWorkout(id: String) async throws -> (WorkoutPlayerViewState, ScreenState)
}

final class WorkoutPlayerServiceImpl: WorkoutPlayerService {

    init(
        client: WorkoutsClient,
        workoutsRepository: WorkoutsCacheRepository,
        actionsRepository: OfflineActionsRepository
    ) {
        self.client = client
        self.workoutsRepository = workoutsRepository
        self.actionsRepository = actionsRepository
    }

    func fetchWorkout(id: String) async throws -> (WorkoutPlayerViewState, ScreenState) {
        do {
            let workout = try await client.fetchWorkout(by: id)
            return (WorkoutPlayerViewState(
                workoutName: workout.name,
                workoutType: workout.type,
                exercises: workout.exercises.map { ExerciseItem(from: $0) }
            ), .loaded)
        } catch {
            guard let data = workoutsRepository.loadWorkout(key: "user", workoutId: id) else {
                throw WorkoutsServiceError.noData
            }
            return (WorkoutPlayerViewState(
                workoutName: data.name,
                workoutType: data.type,
                exercises: data.exercises.map { ExerciseItem(from: $0) }
            ), .offline)
        }
    }
    
    private let client: WorkoutsClient
    private let workoutsRepository: WorkoutsCacheRepository
    private let actionsRepository: OfflineActionsRepository
}
