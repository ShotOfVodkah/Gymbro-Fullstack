import Foundation

public struct ProfileHeaderModel: Equatable, Hashable {
    public let userID: Int
    public let fullName: String
    public let username: String
    public let status: String
    public let subtitle: String
    public let avatarSystemName: String
    public let badge: String?
    
    public init(
        userID: Int,
        fullName: String,
        username: String,
        status: String,
        subtitle: String,
        avatarSystemName: String,
        badge: String?
    ) {
        self.userID = userID
        self.fullName = fullName
        self.username = username
        self.status = status
        self.subtitle = subtitle
        self.avatarSystemName = avatarSystemName
        self.badge = badge
    }
}
