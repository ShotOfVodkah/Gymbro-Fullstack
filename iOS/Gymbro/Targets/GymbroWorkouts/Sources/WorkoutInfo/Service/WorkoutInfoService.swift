import Foundation

import GymbroNetwork
import GymbroTypes

protocol WorkoutInfoService {
    func fetchScreen(id: String, type: WorkoutInfoType) async throws -> (Data, ScreenState)
    func addWorkout(id: String) async throws
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

    func fetchScreen(id: String, type: WorkoutInfoType) async throws -> (Data, ScreenState) {
        do {
            let data = try await networkClient.fetchWorkoutInfoDivJson(with: id, type: type)
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
    
    func addWorkout(id: String) async throws {
        try await networkClient.saveSessionAsWorkout(sessionId: id)
    }

    // MARK: - Private

    private let networkClient: WorkoutsClient
    private let divLocalRepository: DivCacheRepository
    private let actionsRepository: OfflineActionsRepository
    private let localMapper: WorkoutsLocalMapper
}
