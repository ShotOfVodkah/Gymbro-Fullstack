import Foundation

public struct EditProfileScreenModel: Equatable, Hashable {
    public let userID: Int
    public let fullName: String
    public let username: String
    public let status: String
    public let subtitle: String
    public let bio: String
    public let avatarSystemName: String
    
    public init(
        userID: Int,
        fullName: String,
        username: String,
        status: String,
        subtitle: String,
        bio: String,
        avatarSystemName: String
    ) {
        self.userID = userID
        self.fullName = fullName
        self.username = username
        self.status = status
        self.subtitle = subtitle
        self.bio = bio
        self.avatarSystemName = avatarSystemName
    }
}
