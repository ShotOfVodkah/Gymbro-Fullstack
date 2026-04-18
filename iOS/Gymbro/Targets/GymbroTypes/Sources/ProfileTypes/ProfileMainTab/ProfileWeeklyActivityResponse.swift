import Foundation

public struct ProfileWeeklyActivityResponse: Decodable, Hashable {
    public let id: String
    public let day_title: String
    public let value: Int
    public let max_value: Int
    
    public init(
        id: String,
        day_title: String,
        value: Int,
        max_value: Int
    ) {
        self.id = id
        self.day_title = day_title
        self.value = value
        self.max_value = max_value
    }
}
