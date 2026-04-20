import Foundation

public struct ShareProvenance: Hashable {
    public let sourceType: ShareProvenanceSourceType
    public let sourceID: String
    public let sessionID: String

    public init(
        sourceType: ShareProvenanceSourceType,
        sourceID: String,
        sessionID: String
    ) {
        self.sourceType = sourceType
        self.sourceID = sourceID
        self.sessionID = sessionID
    }
}

public enum ShareProvenanceSourceType: String, Hashable {
    case completedSession
}
