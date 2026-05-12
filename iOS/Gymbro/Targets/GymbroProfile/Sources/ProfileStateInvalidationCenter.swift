import Foundation

enum ProfileInvalidationReason: Equatable {
    case accountChanged
    case ownProfileDataChanged
}

@MainActor
final class ProfileStateInvalidationCenter {
    static let shared = ProfileStateInvalidationCenter()

    private var continuations: [UUID: AsyncStream<ProfileInvalidationReason>.Continuation] = [:]

    private init() {}

    func events() -> AsyncStream<ProfileInvalidationReason> {
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

    func invalidate(_ reason: ProfileInvalidationReason) {
        continuations.values.forEach { $0.yield(reason) }
    }
}
