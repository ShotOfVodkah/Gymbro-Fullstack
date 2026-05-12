import Foundation

enum ChallengesInvalidationReason: Equatable {
    case accountChanged
    case listShouldRefresh
}

@MainActor
final class ChallengesStateInvalidationCenter {
    static let shared = ChallengesStateInvalidationCenter()

    private var continuations: [UUID: AsyncStream<ChallengesInvalidationReason>.Continuation] = [:]

    private init() {}

    func events() -> AsyncStream<ChallengesInvalidationReason> {
        let id = UUID()

        return AsyncStream { continuation in
            continuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in
                    self?.continuations[id] = nil
                }
            }
        }
    }

    func invalidate(_ reason: ChallengesInvalidationReason) {
        continuations.values.forEach { $0.yield(reason) }
    }
}
