import Foundation

public enum ProfileViewMode: Equatable, Hashable {
    case myProfile
    case otherUserProfile(userID: Int)
}
