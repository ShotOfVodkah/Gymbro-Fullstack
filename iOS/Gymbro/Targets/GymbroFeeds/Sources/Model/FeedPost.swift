import Foundation

struct FeedPost: Identifiable, Hashable {
    let id: UUID
    let authorName: String
    let authorAvatar: String
    let postedAt: String
    let title: String
    let coverImageName: String
    let category: String
    let duration: String
    let timeAgo: String
    let location: String?
    let description: String
    let exercises: [FeedExercise]
    var likesCount: Int
    var commentsCount: Int
    var isLiked: Bool
    let kind: FeedPostKind
    let isFromJoinedCommunity: Bool

    init(
        id: UUID = UUID(),
        authorName: String,
        authorAvatar: String,
        postedAt: String,
        title: String,
        coverImageName: String,
        category: String,
        duration: String,
        timeAgo: String,
        location: String?,
        description: String,
        exercises: [FeedExercise],
        likesCount: Int,
        commentsCount: Int,
        isLiked: Bool,
        kind: FeedPostKind,
        isFromJoinedCommunity: Bool
    ) {
        self.id = id
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.postedAt = postedAt
        self.title = title
        self.coverImageName = coverImageName
        self.category = category
        self.duration = duration
        self.timeAgo = timeAgo
        self.location = location
        self.description = description
        self.exercises = exercises
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
        self.kind = kind
        self.isFromJoinedCommunity = isFromJoinedCommunity
    }
}

enum FeedPostKind: Hashable {
    case personal
    case friend
    case group
}
