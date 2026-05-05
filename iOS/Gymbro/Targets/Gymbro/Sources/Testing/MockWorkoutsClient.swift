import Foundation
import GymbroNetwork
import GymbroTypes

final class MockWorkoutsClient: WorkoutsClientProtocol {

    func fetchPremadeWorkouts() async throws -> [Workout] { [] }
    func fetchUserWorkouts() async throws -> [Workout] { [] }
    func fetchExercises(type: WorkoutType) async throws -> [ExerciseItemDTO] { [] }

    func createWorkout(_ workout: Workout) async throws -> Workout { workout }
    func editWorkout(_ workout: Workout) async throws -> Workout { workout }

    func fetchWorkout(by id: String) async throws -> Workout {
        Workout(id: id, name: "Mock Workout", type: .strength, exercises: [])
    }

    func fetchWorkoutsList() async throws -> Data { Data() }

    func generateWorkout(prompt: String, injuries: [Injury]) async throws -> Workout {
        Workout(id: UUID().uuidString, name: "Generated", type: .strength, exercises: [])
    }

    func fetchWorkoutInfoTemplates() async throws -> Data { Data() }
    func fetchWorkoutBuilderTitleJson() async throws -> Data { Data() }
    func fetchWorkoutBuilderForTypeDivJson(with type: String, workout: Workout?) async throws -> Data { Data() }
    func fetchWorkoutBuilderSheetJson(with id: String) async throws -> Data { Data() }
    func fetchWorkoutInfoDivJson(with id: String, type: WorkoutInfoType) async throws -> Data { Data() }

    func createSession(workoutId: String, completedAt: String, exercises: [WorkoutExerciseRequest]) async throws -> WorkoutSessionResponse {
        MockDecoder.decode("""
        {
          "id": "session_1",
          "userId": "1",
          "workoutId": "\(workoutId)",
          "workoutName": "Mock Workout",
          "workoutType": "strength",
          "completedAt": "2026-05-05T10:00:00Z",
          "exercises": []
        }
        """)
    }

    func saveSessionAsWorkout(sessionId: String, name: String?, workoutId: String?) async throws -> Workout {
        Workout(id: workoutId ?? "saved", name: name ?? "Saved", type: .strength, exercises: [])
    }

    func deleteWorkout(id: String) async throws {}
    func addPremadeWorkout(premadeId: String) async throws {}
}
