import Foundation

public struct PostsScreenInput: Equatable, Hashable {
    public let userID: Int
    public let userName: String
    public let isOwnProfile: Bool
    
    public init(
        userID: Int,
        userName: String,
        isOwnProfile: Bool
    ) {
        self.userID = userID
        self.userName = userName
        self.isOwnProfile = isOwnProfile
    }
}
