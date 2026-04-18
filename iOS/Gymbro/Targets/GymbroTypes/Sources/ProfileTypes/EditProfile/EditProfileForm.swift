import Foundation

public struct EditProfileForm: Equatable, Hashable {
    public var fullName: String
    public var username: String
    public var status: String
    public var subtitle: String
    public var bio: String
    public var avatarSystemName: String
    
    public init(
        fullName: String,
        username: String,
        status: String,
        subtitle: String,
        bio: String,
        avatarSystemName: String
    ) {
        self.fullName = fullName
        self.username = username
        self.status = status
        self.subtitle = subtitle
        self.bio = bio
        self.avatarSystemName = avatarSystemName
    }
}
