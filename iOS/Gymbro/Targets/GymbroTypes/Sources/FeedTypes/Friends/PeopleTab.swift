import Foundation

public enum PeopleTab: String, CaseIterable, Identifiable {
    case friends
    case following
    case discover

    public var id: String { rawValue }
}
