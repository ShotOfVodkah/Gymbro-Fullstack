import Foundation
import GymbroTypes

public final class OfflineActionsRepository {
    private let ds: OfflineActionsDataSource
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let lock = NSRecursiveLock()
    private let failedFetchLimit = 200
    private let maxRetryBackoffSeconds: TimeInterval = 300

    public init(dataSource: OfflineActionsDataSource) {
        self.ds = dataSource
        self.lock.name = "dev.tuist.gymbro.offline-actions-repository"
    }

    public func enqueue(_ action: OfflineActionDTO) {
        lock.lock()
        defer { lock.unlock() }
        guard let data = try? encoder.encode(action) else { return }
        try? ds.enqueue(data)
    }

    public func enqueueSmart(_ newAction: OfflineActionDTO) {
        lock.lock()
        defer { lock.unlock() }
        let current = pendingActionsOnly()
        let collapsed = collapse(actions: current, with: newAction)
        replaceAllPending(with: collapsed)
    }

    public func pending(limit: Int = 50) -> [(entityId: String, action: OfflineActionDTO)] {
        lock.lock()
        defer { lock.unlock() }
        let now = Date()
        let pendingEntities = (try? ds.fetchPending(limit: limit)) ?? []
        let pendingItems: [(entityId: String, action: OfflineActionDTO)] = pendingEntities.compactMap { e in
            guard let action = try? decoder.decode(OfflineActionDTO.self, from: e.payload) else { return nil }
            return (e.id, action)
        }
        if pendingItems.count >= limit {
            return pendingItems
        }
        let failedEntities = (try? ds.fetchFailed(limit: failedFetchLimit)) ?? []
        let failedItems = failedEntities
            .filter { isReadyToRetry($0, now: now) }
            .prefix(max(0, limit - pendingItems.count))
            .compactMap { e -> (entityId: String, action: OfflineActionDTO)? in
                guard let action = try? decoder.decode(OfflineActionDTO.self, from: e.payload) else { return nil }
                return (e.id, action)
            }
        return pendingItems + failedItems
    }

    public func markSent(entityId: String) {
        lock.lock()
        defer { lock.unlock() }
        try? ds.markSent(id: entityId)
    }
    
    public func markFailed(entityId: String, error: String, retryable: Bool) {
        lock.lock()
        defer { lock.unlock() }
        try? ds.markFailed(id: entityId, error: error, retryable: retryable, attemptedAt: Date())
    }
    
    public func delete(entityId: String) {
        lock.lock()
        defer { lock.unlock() }
        try? ds.delete(id: entityId)
    }
    
    public func clearSent() {
        lock.lock()
        defer { lock.unlock() }
        try? ds.clearSent()
    }

    public func clearAllActions() {
        lock.lock()
        defer { lock.unlock() }
        try? ds.clearAll()
    }

    private func pendingActionsOnly() -> [OfflineActionDTO] {
        guard let entities = try? ds.fetchAllPending() else { return [] }
        return entities.compactMap { try? decoder.decode(OfflineActionDTO.self, from: $0.payload) }
    }

    private func replaceAllPending(with actions: [OfflineActionDTO]) {
        let payloads = actions.compactMap { try? encoder.encode($0) }
        try? ds.replacePending(with: payloads)
    }

    private func collapse(actions: [OfflineActionDTO], with newAction: OfflineActionDTO) -> [OfflineActionDTO] {
        var result = actions

        switch newAction {
        case .addedWorkout(let workout):
            let id = workout.id
            result.removeAll { matchesWorkoutId($0, id: id) }

            result.append(.addedWorkout(workout: workout))
            return result
        case .editedWorkout(let workout):
            let id = workout.id

            if let idx = result.firstIndex(where: { matchesWorkoutId($0, id: id) }) {
                switch result[idx] {
                case .addedWorkout:
                    result[idx] = .addedWorkout(workout: workout)
                    return result

                case .editedWorkout:
                    result[idx] = .editedWorkout(workout: workout)
                    return result

                case .deletedWorkout:
                    return result

                default:
                    result.append(.editedWorkout(workout: workout))
                    return result
                }
            } else {
                result.append(.editedWorkout(workout: workout))
                return result
            }

        case .deletedWorkout(let id):
            let hadAdd = result.contains { if case .addedWorkout(let w) = $0 { return w.id == id } else { return false } }

            result.removeAll { action in
                switch action {
                case .addedWorkout(let w): return w.id == id
                case .editedWorkout(let w): return w.id == id
                case .deletedWorkout(let x): return x == id
                case .completedWorkout: return false
                case .premadeAdded: return false
                }
            }

            if hadAdd {
                return result
            } else {
                result.append(.deletedWorkout(id: id))
                return result
            }
            
        case .completedWorkout(let id, let exercises):
            result.append(.completedWorkout(id: id, exercises: exercises))
            return result

        case .premadeAdded(let id):
            let already = result.contains {
                if case .premadeAdded(let x) = $0 { return x == id }
                return false
            }
            if !already { result.append(.premadeAdded(id: id)) }
            return result
        }
    }

    private func matchesWorkoutId(_ action: OfflineActionDTO, id: String) -> Bool {
        switch action {
        case .addedWorkout(let w): return w.id == id
        case .editedWorkout(let w): return w.id == id
        case .deletedWorkout(let x): return x == id
        case .completedWorkout(let x, _): return x == id
        case .premadeAdded: return false
        }
    }

    private func isReadyToRetry(_ entity: OfflineActionEntity, now: Date) -> Bool {
        guard entity.statusRaw == "failed" else { return false }
        let retryCount = max(entity.retryCount, 1)
        let exponent = max(0, retryCount - 1)
        let computed = min(maxRetryBackoffSeconds, pow(2.0, Double(exponent)) * 5.0)
        guard let attemptedAt = entity.lastAttemptAt else { return true }
        return now.timeIntervalSince(attemptedAt) >= computed
    }
}
