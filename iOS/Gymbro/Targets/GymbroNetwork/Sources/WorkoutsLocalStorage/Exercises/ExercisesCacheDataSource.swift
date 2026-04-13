import Foundation
import SwiftData

public protocol ExercisesCacheDataSource {
    func load(key: String) throws -> Data?
    func save(key: String, data: Data) throws
    func deleteAll() throws
}

public final class ExercisesSwiftDataSource: ExercisesCacheDataSource {
    private let context: ModelContext

    public init(container: ModelContainer) {
        self.context = ModelContext(container)
    }

    public func load(key: String) throws -> Data? {
        let descriptor = FetchDescriptor<ExercisesCache>(
            predicate: #Predicate { $0.key == key }
        )
        return try context.fetch(descriptor).first?.jsonData
    }

    public func save(key: String, data: Data) throws {
        let descriptor = FetchDescriptor<ExercisesCache>(
            predicate: #Predicate { $0.key == key }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.jsonData = data
            existing.updatedAt = .now
        } else {
            context.insert(ExercisesCache(key: key, jsonData: data))
        }
        try context.save()
    }

    public func deleteAll() throws {
        let descriptor = FetchDescriptor<ExercisesCache>()
        let items = try context.fetch(descriptor)
        items.forEach { context.delete($0) }
        try context.save()
    }
}
