import Foundation

public struct ShareWorkoutResponse: Decodable {
    public let created_post_id: String?
    public let delivered_chat_ids: [String]
    public let created_chat_ids: [String]

    public init(
        created_post_id: String?,
        delivered_chat_ids: [String],
        created_chat_ids: [String]
    ) {
        self.created_post_id = created_post_id
        self.delivered_chat_ids = delivered_chat_ids
        self.created_chat_ids = created_chat_ids
    }
}
