import Foundation

public struct FeedComment: Identifiable, Hashable {
    public let id: String
    public let authorName: String
    public let authorAvatarSystemName: String
    public let text: String
    public let createdAt: Date
    public let timeAgo: String
    
    public init(
        id: String,
        authorName: String,
        authorAvatarSystemName: String,
        text: String,
        createdAt: Date,
        timeAgo: String
    ) {
        self.id = id
        self.authorName = authorName
        self.authorAvatarSystemName = authorAvatarSystemName
        self.text = text
        self.createdAt = createdAt
        self.timeAgo = timeAgo
    }
}

extension FeedComment {
    public init(response: FeedCommentResponse) {
        self.id = response.id
        self.authorName = response.author.name
        self.authorAvatarSystemName = response.author.avatar_url
        self.text = response.text
        self.createdAt = response.created_at
        self.timeAgo = Self.timeAgoString(from: response.created_at)
    }
    
    private static func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
