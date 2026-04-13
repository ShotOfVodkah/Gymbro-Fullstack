import Foundation
import GymbroTypes

public final class OfflineActionsRepository {
    private let ds: OfflineActionsDataSource
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(dataSource: OfflineActionsDataSource) {
        self.ds = dataSource
    }

    public func enqueue(_ action: OfflineActionDTO) {
        guard let data = try? encoder.encode(action) else { return }
        try? ds.enqueue(data)
    }

    public func enqueueSmart(_ newAction: OfflineActionDTO) {
        let current = pendingActionsOnly()
        let collapsed = collapse(actions: current, with: newAction)
        replaceAllPending(with: collapsed)
    }

    public func pending(limit: Int = 50) -> [(entityId: String, action: OfflineActionDTO)] {
        guard let entities = try? ds.fetchPending(limit: limit) else { return [] }
        return entities.compactMap { e in
            guard let action = try? decoder.decode(OfflineActionDTO.self, from: e.payload) else { return nil }
            return (e.id, action)
        }
    }

    public func markSent(entityId: String) { try? ds.markSent(id: entityId) }
    public func markFailed(entityId: String, error: String) { try? ds.markFailed(id: entityId, error: error) }
    public func delete(entityId: String) { try? ds.delete(id: entityId) }
    public func clearSent() { try? ds.clearSent() }

    public func clearAllActions() {
        try? ds.clearAll()
    }

    private func pendingActionsOnly() -> [OfflineActionDTO] {
        guard let entities = try? ds.fetchAllPending() else { return [] }
        return entities.compactMap { try? decoder.decode(OfflineActionDTO.self, from: $0.payload) }
    }

    private func replaceAllPending(with actions: [OfflineActionDTO]) {
        try? ds.clearAll()

        for action in actions {
            guard let data = try? encoder.encode(action) else { continue }
            try? ds.enqueue(data)
        }
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
                case .completedWorkout(let x, let y): return x == id
                case .deletedWorkout(let x): return x == id
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
            let already = result.contains {
                if case .completedWorkout(let x, let y) = $0 { return x == id }
                return false
            }
            if !already { result.append(.completedWorkout(id: id, exercises: exercises)) }
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
        case .completedWorkout(let x, let y): return x == id
        case .premadeAdded: return false
        }
    }
}
