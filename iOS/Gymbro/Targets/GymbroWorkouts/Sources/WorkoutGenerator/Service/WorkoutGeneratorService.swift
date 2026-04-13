import Foundation

import GymbroTypes
import GymbroNetwork

protocol WorkoutGeneratorService {
    func generate(prompt: String, injuries: [Injury]) async throws -> (Workout, ScreenState)
    func saveWorkout(_ workout: Workout) async 
}

final class WorkoutGeneratorServiceImpl: WorkoutGeneratorService {

    init(
        client: WorkoutsClient,
        workoutsRepository: WorkoutsCacheRepository,
        actionsRepository: OfflineActionsRepository
    ) {
        self.client = client
        self.actionsRepository = actionsRepository
        self.workoutsRepository = workoutsRepository
    }
    
    func generate(prompt: String, injuries: [Injury]) async throws -> (Workout, ScreenState) {
        let workout = try await client.generateWorkout(prompt: prompt, injuries: injuries)
        return (workout, .loaded)
    }
    
    func saveWorkout(_ workout: Workout) async {
        workoutsRepository.upsertWorkout(key: "user", workout: workout)
        do {
            try await client.createWorkout(workout)
        } catch {
            actionsRepository.enqueueSmart(.addedWorkout(workout: WorkoutDTO(from: workout)))
        }
    }

    private let client: WorkoutsClient
    private let actionsRepository: OfflineActionsRepository
    private let workoutsRepository: WorkoutsCacheRepository
}
