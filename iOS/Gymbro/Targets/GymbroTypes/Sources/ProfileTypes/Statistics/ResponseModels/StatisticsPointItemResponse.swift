import Foundation

public struct StatisticsPointItemResponse: Decodable, Hashable {
    public let id: String
    public let label: String
    public let value: Int
    
    public init(
        id: String,
        label: String,
        value: Int
    ) {
        self.id = id
        self.label = label
        self.value = value
    }
}
