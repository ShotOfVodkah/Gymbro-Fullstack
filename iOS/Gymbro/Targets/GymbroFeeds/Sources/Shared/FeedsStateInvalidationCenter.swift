import Foundation

enum FeedsInvalidationReason: Equatable {
    case feedChanged
    case communitiesChanged
    case peopleChanged
    case calendarChanged
    case chatChanged(chatID: String?)
    case commentsChanged(postID: String?)
    case accountChanged
    case all
}

@MainActor
final class FeedsStateInvalidationCenter {
    static let shared = FeedsStateInvalidationCenter()
    private var continuations: [UUID: AsyncStream<FeedsInvalidationReason>.Continuation] = [:]

    private init() {}

    func events() -> AsyncStream<FeedsInvalidationReason> {
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

    func invalidate(_ reason: FeedsInvalidationReason) {
        continuations.values.forEach { $0.yield(reason) }
    }
}
