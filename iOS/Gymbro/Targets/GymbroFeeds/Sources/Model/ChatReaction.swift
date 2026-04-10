import Foundation

struct ChatReaction: Hashable, Identifiable {
    let id = UUID()
    let emoji: String
    let count: Int
    let isSelectedByMe: Bool
}
