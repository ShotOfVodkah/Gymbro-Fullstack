import Foundation

public struct ChatReaction: Hashable, Identifiable {
    public let id: UUID
    public let emoji: String
    public let count: Int
    public let isSelectedByMe: Bool

    public init(
        id: UUID = UUID(),
        emoji: String,
        count: Int,
        isSelectedByMe: Bool
    ) {
        self.id = id
        self.emoji = emoji
        self.count = count
        self.isSelectedByMe = isSelectedByMe
    }
}
