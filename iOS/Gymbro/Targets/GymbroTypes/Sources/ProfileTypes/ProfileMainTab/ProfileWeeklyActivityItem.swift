import Foundation

public struct ProfileWeeklyActivityItem: Identifiable, Equatable, Hashable {
    public let id: String
    public let dayTitle: String
    public let value: Int
    public let maxValue: Int
    
    public init(
        id: String,
        dayTitle: String,
        value: Int,
        maxValue: Int
    ) {
        self.id = id
        self.dayTitle = dayTitle
        self.value = value
        self.maxValue = maxValue
    }
}
