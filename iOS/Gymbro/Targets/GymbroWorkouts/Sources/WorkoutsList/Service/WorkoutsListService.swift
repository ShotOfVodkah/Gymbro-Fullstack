import Foundation

import GymbroNetwork
import GymbroTypes

protocol WorkoutsListService {
    func fetchScreen() async throws -> (Data, ScreenState)
    func fetchAfterAction() async throws -> (Data, ScreenState)
    func addWorkoutCard(id: String, fromPremade: Bool) -> Data?
    func removeWorkoutCard(id: String) -> Data?
}

final class WorkoutsListServiceImpl: WorkoutsListService {

    init(
        networkClient: WorkoutsClient,
        divLocalRepository: DivCacheRepository,
        workoutsRepository: WorkoutsCacheRepository,
        exercisesRepository: ExercisesRepository,
        localMapper: WorkoutsLocalMapper,
        streakWidget: StreakWidgetControlling
    ) {
        self.networkClient = networkClient
        self.divLocalRepository = divLocalRepository
        self.workoutsRepository = workoutsRepository
        self.exercisesRepository = exercisesRepository
        self.localMapper = localMapper
        self.streakWidget = streakWidget
    }

    func fetchScreen() async throws -> (Data, ScreenState) {
        do {
            try await seedInitialData()
            let data = try await networkClient.fetchWorkoutsList()
            let templates = try await networkClient.fetchWorkoutInfoTemplates()
            divLocalRepository.save(key: "workoutsList", data: data)
            divLocalRepository.save(key: "workoutInfoTemplate", data: templates)
            return (data, .loaded)
        } catch {
            print(error)
            guard let data = divLocalRepository.load(key: "workoutsList") else {
                throw WorkoutsServiceError.noData
            }
            return (data, .offline)
        }
    }
    
    func fetchAfterAction() async throws -> (Data, ScreenState) {
        do {
            try await seedInitialData()
            let data = try await networkClient.fetchWorkoutsList()
            let templates = try await networkClient.fetchWorkoutInfoTemplates()
            divLocalRepository.save(key: "workoutsList", data: data)
            divLocalRepository.save(key: "workoutInfoTemplate", data: templates)
            return (data, .loaded)
        } catch {
            throw WorkoutsServiceError.noData
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

    private let networkClient: WorkoutsClient
    private let divLocalRepository: DivCacheRepository
    private let workoutsRepository: WorkoutsCacheRepository
    private let exercisesRepository: ExercisesRepository
    private let localMapper: WorkoutsLocalMapper
    private let streakWidget: StreakWidgetControlling

    private func seedInitialData() async throws {
        let workouts = try await networkClient.fetchUserWorkouts()
        workoutsRepository.saveWorkouts(key: "user", workouts: workouts)
        for workoutType in [WorkoutType.strength, .cardio, .yoga] {
            let exercises = try await networkClient.fetchExercises(type: workoutType)
            exercisesRepository.save(
                type: AvailableExercisesKey(workoutType: workoutType),
                items: exercises
            )
        }

        let premadeWorkouts = try await networkClient.fetchPremadeWorkouts()
        workoutsRepository.saveWorkouts(key: "premade", workouts: premadeWorkouts)
        
        let streakData = StreakWidgetPayload(weeklyTarget: 5, weeklyProgress: 4, streakValue: 10, daysUntilBurn: 5)
        await streakWidget.applySnapshotFromWorkoutsListLoaded(with: streakData)
    }
}
