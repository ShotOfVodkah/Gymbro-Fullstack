import Foundation

public enum ChatPresentationStyle: Hashable {
    case direct(person: ChatParticipant)
    case group(members: [ChatParticipant])
}
