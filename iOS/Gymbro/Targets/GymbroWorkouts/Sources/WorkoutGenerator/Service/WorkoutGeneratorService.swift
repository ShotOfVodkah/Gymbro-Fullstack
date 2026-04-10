import Foundation

import GymbroTypes
import GymbroNetwork

protocol WorkoutGeneratorService {
    func generate(prompt: String, injuries: [Injury]) async throws -> (Workout, ScreenState)
}

final class WorkoutGeneratorServiceImpl: WorkoutGeneratorService {

    init(
        client: WorkoutsClient,
        workoutsRepository: WorkoutsCacheRepository,
    ) {
        self.client = client
        self.workoutsRepository = workoutsRepository
    }
    
    func generate(prompt: String, injuries: [Injury]) async throws -> (Workout, ScreenState) {
        let workout = try await client.generateWorkout(prompt: prompt, injuries: injuries)
        return (workout, .loaded)
    }

    private let client: WorkoutsClient
    private let workoutsRepository: WorkoutsCacheRepository
}
