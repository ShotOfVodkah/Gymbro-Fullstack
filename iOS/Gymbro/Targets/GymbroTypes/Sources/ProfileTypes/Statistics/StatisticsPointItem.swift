import Foundation

public struct StatisticsPointItem: Identifiable, Equatable, Hashable {
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
