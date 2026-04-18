import Foundation

public struct StatisticsCategoryItemResponse: Decodable, Hashable {
    public let id: String
    public let title: String
    public let value: Int
    
    public init(
        id: String,
        title: String,
        value: Int
    ) {
        self.id = id
        self.title = title
        self.value = value
    }
}
