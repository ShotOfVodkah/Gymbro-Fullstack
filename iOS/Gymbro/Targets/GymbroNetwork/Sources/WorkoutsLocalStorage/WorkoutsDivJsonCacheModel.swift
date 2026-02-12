import Foundation
import SwiftData


@Model
public final class DivJsonCache {
    @Attribute(.unique) var key: String
    var jsonData: Data
    var updatedAt: Date


    public init(key: String, jsonData: Data, updatedAt: Date = .now) {
        self.key = key
        self.jsonData = jsonData
        self.updatedAt = updatedAt
    }
}

