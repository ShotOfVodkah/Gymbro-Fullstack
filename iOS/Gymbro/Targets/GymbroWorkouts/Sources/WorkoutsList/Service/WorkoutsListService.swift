import Foundation

import GymbroNetwork
import GymbroTypes

protocol WorkoutsListService {
    func fetchScreen() async throws -> (Data, ScreenState)
    func addWorkoutCard(id: String, fromPremade: Bool) -> Data?
    func removeWorkoutCard(id: String) -> Data?
}

final class WorkoutsListServiceImpl: WorkoutsListService {

    init(
        networkClient: WorkoutsNetworkClient,
        divLocalRepository: DivCacheRepository,
        workoutsRepository: WorkoutsCacheRepository,
        exercisesRepository: ExercisesRepository,
        localMapper: WorkoutsLocalMapper
    ) {
        self.networkClient = networkClient
        self.divLocalRepository = divLocalRepository
        self.workoutsRepository = workoutsRepository
        self.exercisesRepository = exercisesRepository
        self.localMapper = localMapper
    }

    func fetchScreen() async throws -> (Data, ScreenState) {
        seedInitialData()
        do {
            let data = try await networkClient.fetchWorkoutsDivJson()
            let templates = try await networkClient.fetchWorkoutInfoTemplates()
            divLocalRepository.save(key: "workoutsList", data: data)
            divLocalRepository.save(key: "workoutInfoTemplate", data: templates)
            return (data, .loaded)
        } catch {
            guard let data = divLocalRepository.load(key: "workoutsList") else {
                throw WorkoutsServiceError.noData
            }
            return (data, .offline)
        }
    }

    func addWorkoutCard(id: String, fromPremade: Bool) -> Data? {
        guard
            let data = divLocalRepository.load(key: "workoutsList"),
            let newData = localMapper.addWorkoutCard(to: data, id: id, fromPremade: fromPremade)
        else { return nil }
        divLocalRepository.save(key: "workoutsList", data: newData)
        return newData
    }

    func removeWorkoutCard(id: String) -> Data? {
        guard
            let data = divLocalRepository.load(key: "workoutsList"),
            let newData = localMapper.removeWorkoutCard(from: data, id: id)
        else { return nil }
        divLocalRepository.save(key: "workoutsList", data: newData)
        return newData
    }

    // MARK: - Private

    private let networkClient: WorkoutsNetworkClient
    private let divLocalRepository: DivCacheRepository
    private let workoutsRepository: WorkoutsCacheRepository
    private let exercisesRepository: ExercisesRepository
    private let localMapper: WorkoutsLocalMapper

    private func seedInitialData() {
        workoutsRepository.saveWorkouts(key: "user", workouts: workoutsMock)
        workoutsRepository.saveWorkouts(key: "premade", workouts: premadeWorkouts)
        exercisesRepository.save(type: .cardio, items: cardioExercises.map { ExerciseItemDTO(from: $0) })
        exercisesRepository.save(type: .yoga, items: yogaExercises.map { ExerciseItemDTO(from: $0) })
        exercisesRepository.save(type: .strength, items: strengthExercises.map { ExerciseItemDTO(from: $0) })
    }
}
