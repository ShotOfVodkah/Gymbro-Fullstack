import Foundation

public struct StatisticsMonthCountItemResponse: Decodable, Hashable {
    public let id: String
    public let month_label: String
    public let value: Int
    
    public init(
        id: String,
        month_label: String,
        value: Int
    ) {
        self.id = id
        self.month_label = month_label
        self.value = value
    }
}
