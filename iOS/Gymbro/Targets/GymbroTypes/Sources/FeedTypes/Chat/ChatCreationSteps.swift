import Foundation

public enum ChatCreationStep: Hashable {
    case chooseType
    case chooseDirectPerson
    case createGroup
}

public struct ChatCreationDraft: Hashable {
    public var selectedDirectPerson: PersonItem?
    public var selectedGroupMembers: [PersonItem]
    public var groupName: String

    public init(
        selectedDirectPerson: PersonItem? = nil,
        selectedGroupMembers: [PersonItem] = [],
        groupName: String = ""
    ) {
        self.selectedDirectPerson = selectedDirectPerson
        self.selectedGroupMembers = selectedGroupMembers
        self.groupName = groupName
    }
}
