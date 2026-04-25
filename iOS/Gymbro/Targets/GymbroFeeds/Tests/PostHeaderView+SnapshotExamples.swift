import SwiftUI

@testable import GymbroFeeds

enum PostHeaderViewSnapshotExamples {
    static let snapshotSize = CGSize(width: 400, height: 80)

    static let snapshotExamples: [PostHeaderSnapshotCase] = [
        PostHeaderSnapshotCase(
            name: "default",
            makeView: {
                PostHeaderView(
                    avatar: "person.fill",
                    authorName: "Alex Trainer",
                    postedAt: "2h ago",
                    onAuthorTap: {}
                )
            }
        ),
        PostHeaderSnapshotCase(
            name: "long_name",
            makeView: {
                PostHeaderView(
                    avatar: "flame.fill",
                    authorName: "Very Long Author Name That Might Wrap In UI",
                    postedAt: "Yesterday at 6:12 PM",
                    onAuthorTap: {}
                )
            }
        )
    ]
}

struct PostHeaderSnapshotCase {
    let name: String
    let makeView: () -> PostHeaderView
}
