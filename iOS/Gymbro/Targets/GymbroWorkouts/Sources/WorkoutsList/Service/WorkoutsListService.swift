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
        networkClient: any WorkoutsClientProtocol,
        feedsClient: any FeedsClientProtocol,
        divLocalRepository: DivCacheRepository,
        workoutsRepository: WorkoutsCacheRepository,
        exercisesRepository: ExercisesRepository,
        localMapper: WorkoutsLocalMapper,
        streakWidget: StreakWidgetControlling,
        activityCalendarWidget: ActivityCalendarWidgetControlling
    ) {
        self.networkClient = networkClient
        self.feedsClient = feedsClient
        self.divLocalRepository = divLocalRepository
        self.workoutsRepository = workoutsRepository
        self.exercisesRepository = exercisesRepository
        self.localMapper = localMapper
        self.streakWidget = streakWidget
        self.activityCalendarWidget = activityCalendarWidget
    }

    func fetchScreen() async throws -> (Data, ScreenState) {
        let streak = try? await networkClient.fetchStreak()
        do {
            try await seedInitialData(streak: streak)
            let data = try await networkClient.fetchWorkoutsList(streak: streak)
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
        let streak = try? await networkClient.fetchStreak()
        do {
            try await seedInitialData(streak: streak)
            let data = try await networkClient.fetchWorkoutsList(streak: streak)
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

    private let networkClient: any WorkoutsClientProtocol
    private let feedsClient: any FeedsClientProtocol
    private let divLocalRepository: DivCacheRepository
    private let workoutsRepository: WorkoutsCacheRepository
    private let exercisesRepository: ExercisesRepository
    private let localMapper: WorkoutsLocalMapper
    private let streakWidget: StreakWidgetControlling
    private let activityCalendarWidget: ActivityCalendarWidgetControlling

    private func seedInitialData(streak: StreakResponse?) async throws {
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

        if let streak {
            let streakPayload = StreakWidgetPayload.from(streak: streak)
            await streakWidget.applySnapshotFromWorkoutsListLoaded(with: streakPayload)
        }

        let monthResponse = try await feedsClient.fetchCalendarMonth(
            context: .mine,
            month: Date(),
            selectedPersonID: nil
        )
        let calendarPayload = ActivityCalendarWidgetPayload(response: monthResponse)
        await activityCalendarWidget.applySnapshot(with: calendarPayload)
    }
}
