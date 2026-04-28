import Foundation

public struct PerksEvent: Equatable {
    public let type: PerksEventType
    public let metadata: [String: String]
    public let createdAt: Date
    
    public init(
        type: PerksEventType,
        metadata: [String: String] = [:],
        createdAt: Date = Date()
    ) {
        self.type = type
        self.metadata = metadata
        self.createdAt = createdAt
    }
}
