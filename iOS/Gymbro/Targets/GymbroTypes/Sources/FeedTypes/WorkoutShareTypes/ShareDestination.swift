import Foundation

public enum ShareDestination: Hashable, Identifiable {
    case feed
    case existingChat(id: String, title: String, kind: ShareChatKind)
    case directUser(id: String, name: String, username: String?)
    case community(id: String, title: String)

    public var id: String {
        switch self {
        case .feed:
            return "feed"
        case .existingChat(let id, _, _):
            return "chat:\(id)"
        case .directUser(let id, _, _):
            return "user:\(id)"
        case .community(let id, _):
            return "community:\(id)"
        }
    }
}

public enum ShareChatKind: Hashable {
    case direct
    case group
}
