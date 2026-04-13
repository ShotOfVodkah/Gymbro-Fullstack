import Foundation

public struct CreateFeedCommentRequest: Encodable {
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
}
