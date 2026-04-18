import Foundation

public struct EditProfileResponse: Decodable, Hashable {
    public let user_id: Int
    public let name: String
    public let username: String
    public let status: String
    public let subtitle: String
    public let bio: String
    public let avatar_system_name: String
    
    public init(
        user_id: Int,
        name: String,
        username: String,
        status: String,
        subtitle: String,
        bio: String,
        avatar_system_name: String
    ) {
        self.user_id = user_id
        self.name = name
        self.username = username
        self.status = status
        self.subtitle = subtitle
        self.bio = bio
        self.avatar_system_name = avatar_system_name
    }
}
