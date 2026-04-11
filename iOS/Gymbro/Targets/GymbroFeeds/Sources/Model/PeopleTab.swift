import Foundation

enum PeopleTab: String, CaseIterable, Identifiable {
    case friends = "Friends"
    case discover = "Discover"
    
    var id: String { rawValue }
}
