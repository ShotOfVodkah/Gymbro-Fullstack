import Foundation

public struct StatisticsMonthCountItem: Identifiable, Equatable, Hashable {
    public let id: String
    public let monthLabel: String
    public let value: Int
    
    public init(
        id: String,
        monthLabel: String,
        value: Int
    ) {
        self.id = id
        self.monthLabel = monthLabel
        self.value = value
    }
}
