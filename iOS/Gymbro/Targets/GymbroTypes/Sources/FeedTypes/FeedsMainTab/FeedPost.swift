import Foundation

public struct FeedPost: Identifiable, Hashable {
    public let id: UUID
    public let authorName: String
    public let authorAvatar: String
    public let postedAt: String
    public let title: String
    public let coverImageName: String
    public let category: String
    public let duration: String
    public let timeAgo: String
    public let location: String?
    public let description: String
    public let exercises: [ExerciseItem]
    public var likesCount: Int
    public var commentsCount: Int
    public var isLiked: Bool
    public let kind: FeedPostKind
    public let isFromJoinedCommunity: Bool
    
    public init(
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
        exercises: [ExerciseItem],
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
    
    public static func == (lhs: FeedPost, rhs: FeedPost) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum FeedPostKind: Hashable {
    case personal
    case friend
    case group
}
