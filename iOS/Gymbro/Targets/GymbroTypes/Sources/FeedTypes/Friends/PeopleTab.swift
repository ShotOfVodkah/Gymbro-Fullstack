import Foundation

public enum PeopleTab: String, CaseIterable, Identifiable {
    case friends = "Friends"
    case discover = "Discover"
    
    public var id: String { rawValue }
}
