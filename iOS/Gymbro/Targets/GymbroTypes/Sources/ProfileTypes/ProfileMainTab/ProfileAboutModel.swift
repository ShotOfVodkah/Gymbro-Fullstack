import Foundation

public struct ProfileAboutModel: Equatable, Hashable {
    public let bio: String
    
    public init(bio: String) {
        self.bio = bio
    }
}
