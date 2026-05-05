import Foundation
import GymbroTypes

public protocol WorkoutsClientProtocol {
    func fetchPremadeWorkouts() async throws -> [Workout]
    func fetchUserWorkouts() async throws -> [Workout]
    func fetchExercises(type: WorkoutType) async throws -> [ExerciseItemDTO]

    func createWorkout(_ workout: Workout) async throws -> Workout
    func editWorkout(_ workout: Workout) async throws -> Workout
    func fetchWorkout(by id: String) async throws -> Workout

    func fetchWorkoutsList() async throws -> Data
    func generateWorkout(prompt: String, injuries: [Injury]) async throws -> Workout

    func fetchWorkoutInfoTemplates() async throws -> Data
    func fetchWorkoutBuilderTitleJson() async throws -> Data
    func fetchWorkoutBuilderForTypeDivJson(with type: String, workout: Workout?) async throws -> Data
    func fetchWorkoutBuilderSheetJson(with id: String) async throws -> Data
    func fetchWorkoutInfoDivJson(with id: String, type: WorkoutInfoType) async throws -> Data

    func createSession(
        workoutId: String,
        completedAt: String,
        exercises: [WorkoutExerciseRequest]
    ) async throws -> WorkoutSessionResponse

    func saveSessionAsWorkout(
        sessionId: String,
        name: String?,
        workoutId: String?
    ) async throws -> Workout

    func deleteWorkout(id: String) async throws
    func addPremadeWorkout(premadeId: String) async throws
}

public extension WorkoutsClientProtocol {
    func createSession(
        workoutId: String,
        exercises: [WorkoutExerciseRequest]
    ) async throws -> WorkoutSessionResponse {
        try await createSession(
            workoutId: workoutId,
            completedAt: ISO8601DateFormatter().string(from: Date()),
            exercises: exercises
        )
    }

    func saveSessionAsWorkout(sessionId: String) async throws -> Workout {
        try await saveSessionAsWorkout(sessionId: sessionId, name: nil, workoutId: nil)
    }
}

