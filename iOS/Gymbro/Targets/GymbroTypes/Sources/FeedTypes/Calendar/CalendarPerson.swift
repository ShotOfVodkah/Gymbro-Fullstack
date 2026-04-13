import Foundation

public struct CalendarPerson: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let avatarSystemName: String

    public init(
        id: String,
        name: String,
        avatarSystemName: String
    ) {
        self.id = id
        self.name = name
        self.avatarSystemName = avatarSystemName
    }
}

extension CalendarPerson {
    public init(response: CalendarPersonResponse) {
        self.id = response.id
        self.name = response.name
        self.avatarSystemName = response.avatar_system_name
    }
}
