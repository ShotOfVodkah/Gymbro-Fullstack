import Foundation
import GymbroNetwork
import GymbroTypes

final class MockWorkoutsClient: WorkoutsClientProtocol {

    private var forceOfflinePlayer: Bool {
        ProcessInfo.processInfo.arguments.contains("-uitest-workouts-player-offline")
    }

    func fetchPremadeWorkouts() async throws -> [Workout] { [] }

    func fetchUserWorkouts() async throws -> [Workout] {
        [primaryUITestWorkout()]
    }

    func fetchExercises(type: WorkoutType) async throws -> [ExerciseItemDTO] {
        switch type {
        case .strength:
            return [
                .strength(
                    StrengthExercise(
                        id: WorkoutsUITestConstants.catalogExerciseExtraId,
                        name: "UITest Squat",
                        muscleGroup: .legs,
                        sets: 4,
                        reps: 8,
                        weightKg: 70
                    )
                ),
                .strength(
                    StrengthExercise(
                        id: WorkoutsUITestConstants.catalogExerciseAltId,
                        name: "UITest Pull-Up",
                        muscleGroup: .back,
                        sets: 3,
                        reps: 8,
                        weightKg: 0
                    )
                ),
            ]
        case .cardio:
            return [
                .cardio(
                    CardioExercise(
                        id: "uitest_cat_cardio_run",
                        name: "UITest Easy Run",
                        muscleGroup: .fullBody,
                        durationMinutes: 20,
                        pace: .jog
                    )
                ),
            ]
        case .yoga:
            return [
                .yoga(
                    YogaExercise(
                        id: "uitest_cat_yoga_flow",
                        name: "UITest Yoga Flow",
                        muscleGroup: .core,
                        holdSeconds: 30,
                        breathCount: 5
                    )
                ),
            ]
        }
    }

    func createWorkout(_ workout: Workout) async throws -> Workout { workout }

    func editWorkout(_ workout: Workout) async throws -> Workout { workout }

    func fetchWorkout(by id: String) async throws -> Workout {
        if forceOfflinePlayer, id == WorkoutsUITestConstants.primaryWorkoutId {
            throw NSError(domain: "MockWorkoutsClient", code: 1)
        }
        if id == WorkoutsUITestConstants.generatedWorkoutId {
            return generatedUITestWorkout()
        }
        return primaryUITestWorkout()
    }

    func fetchStreak() async throws -> StreakResponse {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? now

        let formatter = ISO8601DateFormatter()
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)

        return MockDecoder.decode("""
        {
          "currentStreakWeeks": 2,
          "bestStreakWeeks": 4,
          "weeklyGoal": 3,
          "nextWeeklyGoal": 4,
          "completedThisWeek": 1,
          "remainingToGoal": 2,
          "weekStartDate": "\(startString)",
          "weekEndDate": "\(endString)",
          "isGoalCompleted": false,
          "streakFreezeCount": 1,
          "canUseStreakFreeze": true,
          "wasFreezeUsedThisWeek": false
        }
        """)
    }

    func fetchWorkoutsList() async throws -> Data {
        WorkoutsUITestDivPayload.workoutsList()
    }

    func fetchWorkoutsList(streak: StreakResponse?) async throws -> Data {
        try await fetchWorkoutsList()
    }

    func generateWorkout(prompt: String, injuries: [Injury]) async throws -> Workout {
        generatedUITestWorkout()
    }

    func fetchWorkoutInfoTemplates() async throws -> Data {
        WorkoutsUITestDivPayload.workoutInfoTemplates()
    }

    func fetchWorkoutBuilderTitleJson() async throws -> Data {
        WorkoutsUITestDivPayload.workoutBuilderTitle()
    }

    func fetchWorkoutBuilderForTypeDivJson(with type: String, workout: Workout?) async throws -> Data {
        WorkoutsUITestDivPayload.workoutBuilderForType()
    }

    func fetchWorkoutBuilderSheetJson(with id: String) async throws -> Data {
        WorkoutsUITestDivPayload.workoutBuilderSheetStub()
    }

    func fetchWorkoutInfoDivJson(with id: String, type: WorkoutInfoType) async throws -> Data {
        WorkoutsUITestDivPayload.workoutInfo(workoutId: id)
    }

    func createSession(workoutId: String, completedAt: String, exercises: [WorkoutExerciseRequest]) async throws -> WorkoutSessionResponse {
        MockDecoder.decode("""
        {
          "id": "session_\(workoutId)",
          "userId": "1",
          "workoutId": "\(workoutId)",
          "workoutName": "UITest Session",
          "workoutType": "strength",
          "completedAt": "\(completedAt)",
          "exercises": []
        }
        """)
    }

    func saveSessionAsWorkout(sessionId: String, name: String?, workoutId: String?) async throws -> Workout {
        Workout(id: workoutId ?? WorkoutsUITestConstants.generatedWorkoutId, name: name ?? "Saved UITest", type: .strength, exercises: [])
    }

    func deleteWorkout(id: String) async throws {}
    func addPremadeWorkout(premadeId: String) async throws {}

    // MARK: - Factories

    private func primaryUITestWorkout() -> Workout {
        Workout(
            id: WorkoutsUITestConstants.primaryWorkoutId,
            name: "UITest Strength Session",
            type: .strength,
            exercises: [
                StrengthExercise(
                    id: "uitest_primary_exercise",
                    name: "UITest Bench Press",
                    muscleGroup: .chest,
                    sets: 3,
                    reps: 10,
                    weightKg: 42.5
                ),
            ]
        )
    }

    private func generatedUITestWorkout() -> Workout {
        Workout(
            id: WorkoutsUITestConstants.generatedWorkoutId,
            name: "Generated UITest",
            type: .strength,
            exercises: [
                StrengthExercise(
                    id: "uitest_gen_move",
                    name: "UITest Generated Lift",
                    muscleGroup: .shoulders,
                    sets: 2,
                    reps: 12,
                    weightKg: 15
                ),
            ]
        )
    }
}
