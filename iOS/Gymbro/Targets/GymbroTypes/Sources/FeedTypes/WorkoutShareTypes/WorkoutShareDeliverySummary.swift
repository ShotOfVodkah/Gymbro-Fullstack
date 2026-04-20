import Foundation

public struct WorkoutShareDeliverySummary: Hashable {
    public let createdPostID: String?
    public let deliveredChatIDs: [String]
    public let createdChatIDs: [String]

    public init(
        createdPostID: String?,
        deliveredChatIDs: [String],
        createdChatIDs: [String]
    ) {
        self.createdPostID = createdPostID
        self.deliveredChatIDs = deliveredChatIDs
        self.createdChatIDs = createdChatIDs
    }
}

extension WorkoutShareDeliverySummary {
    public init(response: ShareWorkoutResponse) {
        self.init(
            createdPostID: response.created_post_id,
            deliveredChatIDs: response.delivered_chat_ids,
            createdChatIDs: response.created_chat_ids
        )
    }
}

extension WorkoutShareDeliverySummary {
    public var didCreateFeedPost: Bool {
        createdPostID != nil
    }

    public var deliveredChatsCount: Int {
        deliveredChatIDs.count
    }

    public var createdChatsCount: Int {
        createdChatIDs.count
    }

    public var totalDeliveryCount: Int {
        (didCreateFeedPost ? 1 : 0) + deliveredChatsCount
    }
}
