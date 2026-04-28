import Foundation

import GymbroTypes
import GymbroNetwork

protocol WorkoutPlayerService {
    func fetchWorkout(id: String) async throws -> (WorkoutPlayerViewState, ScreenState)
    func submitSession(
        workoutId: String,
        workoutName: String,
        workoutType: WorkoutType,
        exercises: [ExerciseItem],
        weightUpdates: [String: Double]
    ) async -> WorkoutCompletionResult
    func trackWorkoutCompleted(
        startedAt: Date,
        exercises: [ExerciseItem]
    ) async
}

final class WorkoutPlayerServiceImpl: WorkoutPlayerService {

    init(
        client: WorkoutsClient,
        feedsClient: FeedsClient,
        workoutsRepository: WorkoutsCacheRepository,
        actionsRepository: OfflineActionsRepository,
        streakWidget: StreakWidgetControlling,
        activityCalendarWidget: ActivityCalendarWidgetControlling,
        perksEvents: any PerksEventTrackingService
    ) {
        self.client = client
        self.feedsClient = feedsClient
        self.workoutsRepository = workoutsRepository
        self.actionsRepository = actionsRepository
        self.streakWidget = streakWidget
        self.activityCalendarWidget = activityCalendarWidget
        self.perksEvents = perksEvents
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

    func submitSession(
        workoutId: String,
        workoutName: String,
        workoutType: WorkoutType,
        exercises: [ExerciseItem],
        weightUpdates: [String: Double]
    ) async -> WorkoutCompletionResult {
        let sessionExercises: [WorkoutExerciseRequest] = exercises.map { item in
            switch item {
            case .strength(let e):
                let updatedWeight = weightUpdates[e.id] ?? e.weightKg
                return WorkoutExerciseRequest(
                    exerciseId: e.id,
                    sets: e.sets,
                    reps: e.reps,
                    weightKg: updatedWeight
                )
            case .cardio(let e):
                return WorkoutExerciseRequest(
                    exerciseId: e.id,
                    durationMinutes: e.durationMinutes,
                    pace: e.pace
                )
            case .yoga(let e):
                return WorkoutExerciseRequest(
                    exerciseId: e.id,
                    holdSeconds: e.holdSeconds,
                    breathCount: e.breathCount
                )
            default:
                return WorkoutExerciseRequest(from: item.exercise)
            }
        }

        let completionResult: WorkoutCompletionResult

        do {
            let sessionResponse = try await client.createSession(
                workoutId: workoutId,
                exercises: sessionExercises
            )
            await streakWidget.incrementAfterSessionSuccessfullyCreated()
            await applyActivityCalendarSnapshotIfPossible()
            completionResult = .completed(session: CompletedSession(response: sessionResponse))
        } catch {
            actionsRepository.enqueueSmart(.completedWorkout(id: workoutId, exercises: sessionExercises))
            completionResult = .queuedOffline
        }

        let updatedExercises: [any Exercise] = exercises.map { item in
            switch item {
            case .strength(let e):
                let w = weightUpdates[e.id] ?? e.weightKg
                return StrengthExercise(
                    id: e.id,
                    name: e.name,
                    muscleGroup: e.muscleGroup,
                    sets: e.sets,
                    reps: e.reps,
                    weightKg: w
                )
            default:
                return item.exercise
            }
        }

        let workout = Workout(
            id: workoutId,
            name: workoutName,
            type: workoutType,
            exercises: updatedExercises
        )

        workoutsRepository.upsertWorkout(key: "user", workout: workout)

        do {
            try await client.editWorkout(workout)
        } catch {
            actionsRepository.enqueueSmart(.editedWorkout(workout: WorkoutDTO(from: workout)))
        }

        return completionResult
    }
    
    func trackWorkoutCompleted(
        startedAt: Date,
        exercises: [ExerciseItem]
    ) async {
        await perksEvents.trackWorkoutCompleted(
            startedAt: startedAt,
            hasNotes: false,
            muscleGroupsCount: uniqueMuscleGroupsCount(from: exercises)
        )
    }

    private func uniqueMuscleGroupsCount(from exercises: [ExerciseItem]) -> Int {
        let groups = exercises.map { $0.exercise.muscleGroup.rawValue }
        return Set(groups).count
    }

    private let client: WorkoutsClient
    private let feedsClient: FeedsClient
    private let workoutsRepository: WorkoutsCacheRepository
    private let actionsRepository: OfflineActionsRepository
    private let streakWidget: StreakWidgetControlling
    private let activityCalendarWidget: ActivityCalendarWidgetControlling
    private let perksEvents: any PerksEventTrackingService

    private func applyActivityCalendarSnapshotIfPossible() async {
        do {
            let response = try await feedsClient.fetchCalendarMonth(
                context: .mine,
                month: Date(),
                selectedPersonID: nil
            )
            let payload = ActivityCalendarWidgetPayload(response: response)
            await activityCalendarWidget.applySnapshot(with: payload)
        } catch {
        }
    }
}
