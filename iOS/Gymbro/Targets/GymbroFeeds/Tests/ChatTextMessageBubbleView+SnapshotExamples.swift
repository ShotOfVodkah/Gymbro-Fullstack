import Foundation
import GymbroTypes
import SwiftUI

@testable import GymbroFeeds

enum ChatTextMessageBubbleViewSnapshotExamples {
    static let snapshotSize = CGSize(width: 360, height: 140)

    private static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    static let snapshotExamples: [ChatTextBubbleSnapshotCase] = [
        ChatTextBubbleSnapshotCase(
            name: "mine_plain",
            makeView: {
                ChatTextMessageBubbleView(
                    message: ChatMessage(
                        id: "1",
                        senderID: "me",
                        senderName: "You",
                        senderAvatarSystemName: "person",
                        sentAt: fixedDate,
                        isMine: true,
                        kind: .text("On my way to the gym!")
                    ),
                    onReactionTap: { _ in },
                    onLongPress: {}
                )
            }
        ),
        ChatTextBubbleSnapshotCase(
            name: "mine_reactions",
            makeView: {
                ChatTextMessageBubbleView(
                    message: ChatMessage(
                        id: "2",
                        senderID: "me",
                        senderName: "You",
                        senderAvatarSystemName: "person",
                        sentAt: fixedDate,
                        isMine: true,
                        kind: .text("Great set today 💪"),
                        reactions: [
                            ChatReaction(emoji: "🔥", count: 3, isSelectedByMe: true),
                            ChatReaction(emoji: "👍", count: 1, isSelectedByMe: false)
                        ]
                    ),
                    onReactionTap: { _ in },
                    onLongPress: {}
                )
            }
        ),
        ChatTextBubbleSnapshotCase(
            name: "theirs_plain",
            makeView: {
                ChatTextMessageBubbleView(
                    message: ChatMessage(
                        id: "3",
                        senderID: "partner",
                        senderName: "Alex",
                        senderAvatarSystemName: "person.2",
                        sentAt: fixedDate,
                        isMine: false,
                        kind: .text("Let me know when you're free")
                    ),
                    onReactionTap: { _ in },
                    onLongPress: {}
                )
            }
        ),
        ChatTextBubbleSnapshotCase(
            name: "theirs_reactions",
            makeView: {
                ChatTextMessageBubbleView(
                    message: ChatMessage(
                        id: "4",
                        senderID: "partner",
                        senderName: "Very Long Display Name",
                        senderAvatarSystemName: "person.2",
                        sentAt: fixedDate,
                        isMine: false,
                        kind: .text("Sounds good!"),
                        reactions: [
                            ChatReaction(emoji: "❤️", count: 2, isSelectedByMe: false)
                        ]
                    ),
                    onReactionTap: { _ in },
                    onLongPress: {}
                )
            }
        )
    ]
}

struct ChatTextBubbleSnapshotCase {
    let name: String
    let makeView: () -> ChatTextMessageBubbleView
}
