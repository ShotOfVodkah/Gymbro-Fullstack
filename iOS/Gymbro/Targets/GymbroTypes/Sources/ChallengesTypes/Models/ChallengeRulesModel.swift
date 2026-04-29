import Foundation

public struct ChallengeRulesModel: Identifiable, Hashable {
    public let id: String
    public let text: String
    
    public init(
        id: String = UUID().uuidString,
        text: String
    ) {
        self.id = id
        self.text = text
    }
}
