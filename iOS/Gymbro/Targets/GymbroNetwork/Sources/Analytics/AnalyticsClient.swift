import Foundation
import GymbroTypes

public final class AnalyticsClient {
    private let networkClient: NetworkClient

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func sendBatch(_ events: [AnalyticsEventDTO]) async throws {
        try await networkClient.requestVoid(
            method: .POST,
            path: "analytics/events",
            body: events,
            requiresAuth: true
        )
    }
}
