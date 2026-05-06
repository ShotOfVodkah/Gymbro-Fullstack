import Foundation
import SwiftData

@Model
public final class OfflineActionEntity {
    @Attribute(.unique) public var id: String
    public var payload: Data
    public var createdAt: Date
    public var statusRaw: String
    public var lastError: String?
    public var retryCount: Int
    public var lastAttemptAt: Date?

    public init(
        id: String = UUID().uuidString,
        payload: Data,
        createdAt: Date = .now,
        statusRaw: String = "pending",
        lastError: String? = nil,
        retryCount: Int = 0,
        lastAttemptAt: Date? = nil
    ) {
        self.id = id
        self.payload = payload
        self.createdAt = createdAt
        self.statusRaw = statusRaw
        self.lastError = lastError
        self.retryCount = retryCount
        self.lastAttemptAt = lastAttemptAt
    }
}
