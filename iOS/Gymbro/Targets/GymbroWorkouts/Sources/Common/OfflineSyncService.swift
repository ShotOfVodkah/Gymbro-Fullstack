import Foundation
import Combine
import GymbroNetwork
import GymbroTypes

public final class OfflineSyncService {

    public init(
        actionsRepository: OfflineActionsRepository,
        networkClient: any WorkoutsClientProtocol,
        feedsClient: any FeedsClientProtocol,
        modelModifier: WorkoutsModelModifier,
        streakWidget: StreakWidgetControlling,
        activityCalendarWidget: ActivityCalendarWidgetControlling,
        connectivityProvider: ConnectivityStatusProviding? = nil
    ) {
        self.actionsRepository = actionsRepository
        self.networkClient = networkClient
        self.feedsClient = feedsClient
        self.modelModifier = modelModifier
        self.streakWidget = streakWidget
        self.activityCalendarWidget = activityCalendarWidget
        self.connectivityProvider = connectivityProvider
    }

    public func start() {
        connectivityProvider?.startMonitoring()
        modelModifier.events
            .sink { [weak self] event in
                if case .statusChanged(let status) = event, status == .online {
                    self?.requestFlush()
                }
            }
            .store(in: &cancellables)
        connectivityProvider?.statusPublisher
            .removeDuplicates()
            .sink { [weak self] isOnline in
                guard isOnline else { return }
                self?.requestFlush()
            }
            .store(in: &cancellables)
        if connectivityProvider?.isOnline == true {
            requestFlush()
        }
    }

    private let actionsRepository: OfflineActionsRepository
    private let networkClient: any WorkoutsClientProtocol
    private let feedsClient: any FeedsClientProtocol
    private let modelModifier: WorkoutsModelModifier
    private let streakWidget: StreakWidgetControlling
    private let activityCalendarWidget: ActivityCalendarWidgetControlling
    private let connectivityProvider: ConnectivityStatusProviding?
    private var cancellables = Set<AnyCancellable>()
    private let flushStateQueue = DispatchQueue(label: "dev.tuist.gymbro.offline-sync.flush-state")
    private let batchSize = 50
    private var isFlushing = false
    private var needsAnotherFlush = false

    private func requestFlush() {
        let shouldStart = flushStateQueue.sync { () -> Bool in
            if isFlushing {
                needsAnotherFlush = true
                return false
            }
            isFlushing = true
            return true
        }
        guard shouldStart else { return }
        Task { [weak self] in
            await self?.flushLoop()
        }
    }

    private func flushLoop() async {
        while true {
            var didProcessAtLeastOneAction = false
            while true {
                let pending = actionsRepository.pending(limit: batchSize)
                guard !pending.isEmpty else { break }
                didProcessAtLeastOneAction = true
                for (entityId, action) in pending {
                    do {
                        try await execute(action)
                        actionsRepository.delete(entityId: entityId)
                    } catch {
                        let retryable = shouldRetry(error)
                        actionsRepository.markFailed(
                            entityId: entityId,
                            error: error.localizedDescription,
                            retryable: retryable
                        )
                    }
                }
            }
            if didProcessAtLeastOneAction {
                modelModifier.events.send(.forceReload)
            }
            let continueFlush = flushStateQueue.sync { () -> Bool in
                if needsAnotherFlush {
                    needsAnotherFlush = false
                    return true
                }
                isFlushing = false
                return false
            }
            guard continueFlush else { break }
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

    private func shouldRetry(_ error: Error) -> Bool {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet, .hostNotFound, .cancelled:
                return true
            case .serverError(let code):
                return (500..<600).contains(code)
            case .unknown(let wrapped):
                return wrapped is URLError
            case .invalidURL, .invalidResponse, .unauthorized, .decodingError, .encodingError:
                return false
            }
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return true
            default:
                return false
            }
        }
        return false
    }
}
