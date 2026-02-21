import Foundation
import SwiftData

public protocol WorkoutsCacheDataSource {
    func load(key: String) throws -> Data?
    func save(key: String, data: Data) throws
}

public final class WorkoutsSwiftDataCacheDataSource: WorkoutsCacheDataSource {
    private let context: ModelContext

    public init(container: ModelContainer) {
        self.context = ModelContext(container)
    }

    public func load(key: String) throws -> Data? {
        let descriptor = FetchDescriptor<WorkoutsCache>(
            predicate: #Predicate { $0.key == key }
        )
        return try context.fetch(descriptor).first?.jsonData
    }

    public func save(key: String, data: Data) throws {
        let descriptor = FetchDescriptor<WorkoutsCache>(
            predicate: #Predicate { $0.key == key }
        )

        if let existing = try context.fetch(descriptor).first {
            existing.jsonData = data
            existing.updatedAt = .now
        } else {
            context.insert(WorkoutsCache(key: key, jsonData: data))
        }
        try context.save()
    }
}
