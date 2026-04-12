import Foundation

public struct PersonItem: Identifiable, Hashable {
    public let id: String
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
        id: String,
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
    
    public func toggledFollow(isCurrentFriend: Bool? = nil) -> PersonItem {
        PersonItem(
            id: id,
            name: name,
            username: username,
            status: status,
            subtitle: subtitle,
            avatarSystemName: avatarSystemName,
            isFollowing: !isFollowing,
            isCurrentFriend: isCurrentFriend ?? self.isCurrentFriend,
            badge: badge,
            workoutsThisMonth: workoutsThisMonth
        )
    }
}

extension PersonItem {
    public init(response: PersonItemResponse) {
        self.id = response.id
        self.name = response.name
        self.username = response.username
        self.status = response.status
        self.subtitle = response.subtitle
        self.avatarSystemName = response.avatar_system_name
        self.isFollowing = response.is_following
        self.isCurrentFriend = response.is_current_friend
        self.badge = response.badge
        self.workoutsThisMonth = response.workouts_this_month
    }
}
