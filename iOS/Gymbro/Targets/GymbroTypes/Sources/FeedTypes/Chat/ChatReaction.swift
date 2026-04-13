import Foundation

public struct ChatReaction: Hashable, Identifiable {
    public var id: String { "\(emoji)-\(isSelectedByMe)-\(count)" }
    public let emoji: String
    public let count: Int
    public let isSelectedByMe: Bool

    public init(
        emoji: String,
        count: Int,
        isSelectedByMe: Bool
    ) {
        self.emoji = emoji
        self.count = count
        self.isSelectedByMe = isSelectedByMe
    }
}

extension ChatReaction {
    public init(response: ChatReactionResponse) {
        self.init(
            emoji: response.emoji,
            count: response.count,
            isSelectedByMe: response.is_selected_by_me
        )
    }
}
