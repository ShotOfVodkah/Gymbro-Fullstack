import Foundation

import GymbroNetwork
import GymbroTypes

protocol WorkoutBuilderForTypeService {
    func fetchScreen(type: String, workout: Workout?, selectedExerciseIds: [String]) async throws -> (Data, ScreenState)
    func loadWorkout(id: String) -> Workout?
    func loadAvailableExercises(type: String) -> [any Exercise]
    func saveWorkout(_ workout: Workout)
    func enqueueAddWorkout(_ workout: Workout)
    func enqueueEditWorkout(_ workout: Workout)
}

final class WorkoutBuilderForTypeServiceImpl: WorkoutBuilderForTypeService {

    init(
        networkClient: WorkoutsNetworkClient,
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

    func loadAvailableExercises(type: String) -> [any Exercise] {
        let key: AvailableExercisesKey
        let fallback: [any Exercise]

        switch type {
        case "Yoga":
            key = .yoga
            fallback = yogaExercises
        case "Cardio":
            key = .cardio
            fallback = cardioExercises
        case "Strength":
            key = .strength
            fallback = strengthExercises
        default:
            return []
        }

        let fromRepo = exercisesRepository.load(type: key).map(\.asExercise)
        return fromRepo.isEmpty ? fallback : fromRepo
    }

    func saveWorkout(_ workout: Workout) {
        workoutsRepository.upsertWorkout(key: "user", workout: workout)
    }

    func enqueueAddWorkout(_ workout: Workout) {
        actionsRepository.enqueueSmart(.addedWorkout(workout: WorkoutDTO(from: workout)))
    }

    func enqueueEditWorkout(_ workout: Workout) {
        actionsRepository.enqueueSmart(.editedWorkout(workout: WorkoutDTO(from: workout)))
    }

    // MARK: - Private

    private let networkClient: WorkoutsNetworkClient
    private let divLocalRepository: DivCacheRepository
    private let workoutsRepository: WorkoutsCacheRepository
    private let exercisesRepository: ExercisesRepository
    private let actionsRepository: OfflineActionsRepository
    private let localMapper: WorkoutsLocalMapper
}
