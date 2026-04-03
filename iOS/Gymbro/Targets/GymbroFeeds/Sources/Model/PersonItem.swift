import Foundation

struct PersonItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let username: String
    let status: String
    let subtitle: String
    let avatarSystemName: String
    let isFollowing: Bool
    let isCurrentFriend: Bool
    let badge: String?
    let workoutsThisMonth: Int
    
    init(
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
}
