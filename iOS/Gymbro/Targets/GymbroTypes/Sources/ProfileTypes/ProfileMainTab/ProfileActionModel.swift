import Foundation

public struct ProfileActionModel: Identifiable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let iconSystemName: String
    public let kind: ActionKind
    
    public init(
        id: String,
        title: String,
        iconSystemName: String,
        kind: ActionKind
    ) {
        self.id = id
        self.title = title
        self.iconSystemName = iconSystemName
        self.kind = kind
    }
}

public enum ProfileActionKind: Equatable, Hashable {
    case editProfile
    case settings
    case posts
    case friends
    case workoutCalendar
    case statistics
    case logout
}

public extension ProfileActionModel {
    typealias ActionKind = ProfileActionKind
}
