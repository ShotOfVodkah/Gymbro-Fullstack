import Foundation

public struct ShareActionDraft: Hashable {
    public var sessionID: String
    public var caption: String
    public var location: String?
    public var publishToFeed: Bool
    public var destinations: [ShareDestination]

    public init(
        sessionID: String,
        caption: String = "",
        location: String? = nil,
        publishToFeed: Bool = true,
        destinations: [ShareDestination] = []
    ) {
        self.sessionID = sessionID
        self.caption = caption
        self.location = location
        self.publishToFeed = publishToFeed
        self.destinations = destinations
    }
}
