import Foundation

import GymbroNetwork
import GymbroTypes

protocol WorkoutInfoService {
    func fetchScreen(id: String) async throws -> (Data, ScreenState)
    func deleteWorkout(id: String) async
}

final class WorkoutInfoServiceImpl: WorkoutInfoService {

    init(
        networkClient: WorkoutsClient,
        divLocalRepository: DivCacheRepository,
        actionsRepository: OfflineActionsRepository,
        localMapper: WorkoutsLocalMapper
    ) {
        self.networkClient = networkClient
        self.divLocalRepository = divLocalRepository
        self.actionsRepository = actionsRepository
        self.localMapper = localMapper
    }

    func fetchScreen(id: String) async throws -> (Data, ScreenState) {
        do {
            let data = try await networkClient.fetchWorkoutInfoDivJson(with: id)
            return (data, .loaded)
        } catch {
            guard let data = localMapper.renderWorkoutInfo(id: id) else {
                throw WorkoutsServiceError.noData
            }
            return (data, .offline)
        }
    }

    func deleteWorkout(id: String) async {
        do {
            try await networkClient.deleteWorkout(id: id)
        } catch {
            actionsRepository.enqueueSmart(.deletedWorkout(id: id))
        }
    }

    // MARK: - Private

    private let networkClient: WorkoutsClient
    private let divLocalRepository: DivCacheRepository
    private let actionsRepository: OfflineActionsRepository
    private let localMapper: WorkoutsLocalMapper
}
