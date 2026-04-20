import Foundation

public struct ShareWorkoutRequest: Encodable {
    public let session_id: String
    public let publish_to_feed: Bool
    public let existing_chat_ids: [String]
    public let direct_user_ids: [String]
    public let description: String
    public let location: String?

    public init(
        session_id: String,
        publish_to_feed: Bool,
        existing_chat_ids: [String],
        direct_user_ids: [String],
        description: String,
        location: String?
    ) {
        self.session_id = session_id
        self.publish_to_feed = publish_to_feed
        self.existing_chat_ids = existing_chat_ids
        self.direct_user_ids = direct_user_ids
        self.description = description
        self.location = location
    }
}
