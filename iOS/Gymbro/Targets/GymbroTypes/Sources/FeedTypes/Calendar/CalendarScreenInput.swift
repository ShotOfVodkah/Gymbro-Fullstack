import Foundation

public struct CalendarScreenInput: Hashable {
    public let context: CalendarContext
    
    public init(context: CalendarContext) {
        self.context = context
    }
}

public enum CalendarContext: Hashable {
    case mine
    case person(personID: String, personName: String)
    case directChat(chatID: String, participantIDs: [String], initialPersonID: String?)
    case groupChat(chatID: String, groupID: String, initialPersonID: String?)
}

public enum CalendarWorkoutOwner {
    case mine
    case partner
}
