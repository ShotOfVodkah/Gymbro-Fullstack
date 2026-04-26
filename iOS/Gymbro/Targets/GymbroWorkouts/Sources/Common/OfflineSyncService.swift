import Foundation
import Combine
import GymbroNetwork
import GymbroTypes

public final class OfflineSyncService {

    public init(
        actionsRepository: OfflineActionsRepository,
        networkClient: WorkoutsClient,
        feedsClient: FeedsClient,
        modelModifier: WorkoutsModelModifier,
        streakWidget: StreakWidgetControlling,
        activityCalendarWidget: ActivityCalendarWidgetControlling
    ) {
        self.actionsRepository = actionsRepository
        self.networkClient = networkClient
        self.feedsClient = feedsClient
        self.modelModifier = modelModifier
        self.streakWidget = streakWidget
        self.activityCalendarWidget = activityCalendarWidget
    }

    public func start() {
        modelModifier.events
            .sink { [weak self] event in
                if case .statusChanged(let status) = event, status == .online {
                    Task { await self?.flush() }
                }
            }
            .store(in: &cancellables)
    }

    private let actionsRepository: OfflineActionsRepository
    private let networkClient: WorkoutsClient
    private let feedsClient: FeedsClient
    private let modelModifier: WorkoutsModelModifier
    private let streakWidget: StreakWidgetControlling
    private let activityCalendarWidget: ActivityCalendarWidgetControlling
    private var cancellables = Set<AnyCancellable>()

    private func flush() async {
        let pending = actionsRepository.pending()
        for (entityId, action) in pending {
            do {
                try await execute(action)
                actionsRepository.delete(entityId: entityId)
            } catch {
                actionsRepository.markFailed(entityId: entityId, error: error.localizedDescription)
            }
        }
        if !pending.isEmpty {
            modelModifier.events.send(.forceReload)
        }
    }

    private func execute(_ action: OfflineActionDTO) async throws {
        switch action {
        case .addedWorkout(let dto):
            _ = try await networkClient.createWorkout(dto.toWorkout())
        case .editedWorkout(let dto):
            _ = try await networkClient.editWorkout(dto.toWorkout())
        case .deletedWorkout(let id):
            try await networkClient.deleteWorkout(id: id)
        case .premadeAdded(let id):
            _ = try await networkClient.addPremadeWorkout(premadeId: id)
        case .completedWorkout(let id, let exercises):
            try await networkClient.createSession(workoutId: id, exercises: exercises)
            await streakWidget.incrementAfterSessionSuccessfullyCreated()
            await applyActivityCalendarSnapshotIfPossible()
        }
    }

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
