import SwiftUI

@testable import GymbroFeeds

enum PostMetaTagsViewSnapshotExamples {
    static let snapshotSize = CGSize(width: 420, height: 56)

    static let snapshotExamples: [PostMetaTagsSnapshotCase] = [
        PostMetaTagsSnapshotCase(
            name: "default",
            makeView: {
                PostMetaTagsView(
                    category: "HIIT",
                    duration: "45 min",
                    timeAgo: "1h"
                )
            }
        ),
        PostMetaTagsSnapshotCase(
            name: "long_labels",
            makeView: {
                PostMetaTagsView(
                    category: "Strength & Cardio",
                    duration: "90 min",
                    timeAgo: "Yesterday"
                )
            }
        )
    ]
}

struct PostMetaTagsSnapshotCase {
    let name: String
    let makeView: () -> PostMetaTagsView
}
