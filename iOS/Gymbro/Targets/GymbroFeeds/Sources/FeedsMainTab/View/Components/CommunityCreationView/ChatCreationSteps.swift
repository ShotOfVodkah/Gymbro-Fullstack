import Foundation

enum ChatCreationStep: Hashable {
    case chooseType
    case chooseDirectPerson
    case createGroup
}

struct ChatCreationDraft: Hashable {
    var selectedDirectPerson: PersonItem?
    var selectedGroupMembers: [PersonItem] = []
    var groupName: String = ""
}
