import Foundation

public struct PersonItemResponse: Decodable {
    public let id: String
    public let name: String
    public let username: String
    public let status: String
    public let subtitle: String
    public let avatar_system_name: String
    public let is_following: Bool
    public let is_current_friend: Bool
    public let badge: String?
    public let workouts_this_month: Int

    public init(
        id: String,
        name: String,
        username: String,
        status: String,
        subtitle: String,
        avatar_system_name: String,
        is_following: Bool,
        is_current_friend: Bool,
        badge: String?,
        workouts_this_month: Int
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.status = status
        self.subtitle = subtitle
        self.avatar_system_name = avatar_system_name
        self.is_following = is_following
        self.is_current_friend = is_current_friend
        self.badge = badge
        self.workouts_this_month = workouts_this_month
    }
}
