import Foundation

import GymbroNetwork
import GymbroTypes

protocol WorkoutBuilderForTypeService {
    func fetchScreen(type: String, workout: Workout?, selectedExerciseIds: [String]) async throws -> (Data, ScreenState)
    func loadWorkout(id: String) -> Workout?
    func fetchAvailableExercises(type: String) async -> [any Exercise]
    func saveWorkout(_ workout: Workout) async
    func editWorkout(_ workout: Workout) async
}

final class WorkoutBuilderForTypeServiceImpl: WorkoutBuilderForTypeService {

    init(
        networkClient: WorkoutsClient,
        divLocalRepository: DivCacheRepository,
        workoutsRepository: WorkoutsCacheRepository,
        exercisesRepository: ExercisesRepository,
        actionsRepository: OfflineActionsRepository,
        localMapper: WorkoutsLocalMapper
    ) {
        self.networkClient = networkClient
        self.divLocalRepository = divLocalRepository
        self.workoutsRepository = workoutsRepository
        self.exercisesRepository = exercisesRepository
        self.actionsRepository = actionsRepository
        self.localMapper = localMapper
    }

    func fetchScreen(type: String, workout: Workout?, selectedExerciseIds: [String]) async throws -> (Data, ScreenState) {
        do {
            let data = try await networkClient.fetchWorkoutBuilderForTypeDivJson(with: type, workout: workout)
            divLocalRepository.save(key: "workoutBuilderFor\(type)", data: data)
            return (data, .loaded)
        } catch {
            guard let data = divLocalRepository.load(key: "workoutBuilderFor\(type)") else {
                throw WorkoutsServiceError.noData
            }
            if !selectedExerciseIds.isEmpty,
               let expanded = localMapper.expandExercises(in: data, exerciseIds: selectedExerciseIds) {
                return (expanded, .offline)
            }
            return (data, .offline)
        }
    }

    func loadWorkout(id: String) -> Workout? {
        workoutsRepository.loadWorkout(key: "user", workoutId: id)
    }

    func fetchAvailableExercises(type: String) async -> [any Exercise] {
        let workoutType: WorkoutType
        let key: AvailableExercisesKey

        switch type {
        case "Yoga":     workoutType = .yoga;     key = .yoga
        case "Cardio":   workoutType = .cardio;   key = .cardio
        case "Strength": workoutType = .strength; key = .strength
        default: return []
        }

        do {
            let items = try await networkClient.fetchExercises(type: workoutType)
            exercisesRepository.save(type: key, items: items)
            return items.map(\.asExercise)
        } catch {
            return exercisesRepository.load(type: key).map(\.asExercise)
        }
    }

    func saveWorkout(_ workout: Workout) async {
        workoutsRepository.upsertWorkout(key: "user", workout: workout)
        do {
            try await networkClient.createWorkout(workout)
        } catch {
            actionsRepository.enqueueSmart(.addedWorkout(workout: WorkoutDTO(from: workout)))
        }
    }

    func editWorkout(_ workout: Workout) async {
        workoutsRepository.upsertWorkout(key: "user", workout: workout)
        do {
            try await networkClient.editWorkout(workout)
        } catch {
            actionsRepository.enqueueSmart(.editedWorkout(workout: WorkoutDTO(from: workout)))
        }
    }

    // MARK: - Private

    private let networkClient: WorkoutsClient
    private let divLocalRepository: DivCacheRepository
    private let workoutsRepository: WorkoutsCacheRepository
    private let exercisesRepository: ExercisesRepository
    private let actionsRepository: OfflineActionsRepository
    private let localMapper: WorkoutsLocalMapper
}
