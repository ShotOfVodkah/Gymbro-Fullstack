import Foundation

import GymbroNetwork
import GymbroTypes

protocol WorkoutBuilderService {
    func fetchScreen() async throws -> (Data, ScreenState)
    func fetchSheet(id: String) async throws -> Data
    func addPremadeWorkout(id: String) async
}

final class WorkoutBuilderServiceImpl: WorkoutBuilderService {

    init(
        networkClient: any WorkoutsClientProtocol,
        divLocalRepository: DivCacheRepository,
        actionsRepository: OfflineActionsRepository,
        localMapper: WorkoutsLocalMapper
    ) {
        self.networkClient = networkClient
        self.divLocalRepository = divLocalRepository
        self.actionsRepository = actionsRepository
        self.localMapper = localMapper
    }

    func fetchScreen() async throws -> (Data, ScreenState) {
        do {
            let data = try await networkClient.fetchWorkoutBuilderTitleJson()
            divLocalRepository.save(key: "workoutBuilderTitle", data: data)
            return (data, .loaded)
        } catch {
            guard let data = divLocalRepository.load(key: "workoutBuilderTitle") else {
                throw WorkoutsServiceError.noData
            }
            return (data, .offline)
        }
    }

    func fetchSheet(id: String) async throws -> Data {
        do {
            return try await networkClient.fetchWorkoutBuilderSheetJson(with: id)
        } catch {
            guard let data = localMapper.renderWorkoutBuilder(id: id) else {
                throw WorkoutsServiceError.noData
            }
            return data
        }
    }

    func addPremadeWorkout(id: String) async {
        do {
            try await networkClient.addPremadeWorkout(premadeId: id)
        } catch {
            actionsRepository.enqueueSmart(.premadeAdded(id: id))
        }
    }

    // MARK: - Private

    private let networkClient: any WorkoutsClientProtocol
    private let divLocalRepository: DivCacheRepository
    private let actionsRepository: OfflineActionsRepository
    private let localMapper: WorkoutsLocalMapper
}
