import Foundation

public struct PersonItem: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let username: String
    public let status: String
    public let subtitle: String
    public let avatarSystemName: String
    public let isFollowing: Bool
    public let isCurrentFriend: Bool
    public let badge: String?
    public let workoutsThisMonth: Int
    
    public init(
        id: UUID = UUID(),
        name: String,
        username: String,
        status: String,
        subtitle: String,
        avatarSystemName: String,
        isFollowing: Bool,
        isCurrentFriend: Bool,
        badge: String? = nil,
        workoutsThisMonth: Int
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.status = status
        self.subtitle = subtitle
        self.avatarSystemName = avatarSystemName
        self.isFollowing = isFollowing
        self.isCurrentFriend = isCurrentFriend
        self.badge = badge
        self.workoutsThisMonth = workoutsThisMonth
    }
    
    public func toggledFollow() -> PersonItem {
        PersonItem(
            id: id,
            name: name,
            username: username,
            status: status,
            subtitle: subtitle,
            avatarSystemName: avatarSystemName,
            isFollowing: !isFollowing,
            isCurrentFriend: isCurrentFriend,
            badge: badge,
            workoutsThisMonth: workoutsThisMonth
        )
    }
}
