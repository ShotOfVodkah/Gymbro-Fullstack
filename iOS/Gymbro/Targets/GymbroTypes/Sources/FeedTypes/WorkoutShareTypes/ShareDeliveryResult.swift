import Foundation

public struct ShareDeliveryResult: Hashable {
    public let createdPostID: String?
    public let deliveredChatIDs: [String]
    public let createdChatIDs: [String]
    public let failedDestinationIDs: [String]

    public init(
        createdPostID: String? = nil,
        deliveredChatIDs: [String] = [],
        createdChatIDs: [String] = [],
        failedDestinationIDs: [String] = []
    ) {
        self.createdPostID = createdPostID
        self.deliveredChatIDs = deliveredChatIDs
        self.createdChatIDs = createdChatIDs
        self.failedDestinationIDs = failedDestinationIDs
    }
}
