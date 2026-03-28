import Foundation

import GymbroTypes

public final class WorkoutsClient {
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    public func fetchWorkout(by id: String) async throws -> Workout {
        let dto = try await client.request(
            method: .GET,
//            path: "workouts/\(id)",
            path: "workouts/workout-1",
            body: Optional<EmptyBody>.none,
            requiresAuth: false,
            responseType: WorkoutDTO.self
        )
            
        return dto.toWorkout()
    }
    
    private let client: NetworkClient
    private let userId: String = "sample"
    
}

