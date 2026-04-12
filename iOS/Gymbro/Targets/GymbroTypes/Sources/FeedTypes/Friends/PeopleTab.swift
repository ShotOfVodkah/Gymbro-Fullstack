import Foundation

public enum PeopleTab: String, CaseIterable, Identifiable {
    case friends = "Friends"
    case following = "Following"
    case discover = "Discover"
    
    public var id: String { rawValue }
}
