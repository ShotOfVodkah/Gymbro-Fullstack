import Foundation
import SwiftData

public protocol OfflineActionsDataSource {
    func enqueue(_ data: Data) throws
    func fetchPending(limit: Int) throws -> [OfflineActionEntity]
    func fetchAllPending() throws -> [OfflineActionEntity]
    func fetchFailed(limit: Int) throws -> [OfflineActionEntity]
    func replacePending(with payloads: [Data]) throws

    func markSent(id: String) throws
    func markFailed(id: String, error: String, retryable: Bool, attemptedAt: Date) throws
    func delete(id: String) throws
    func clearAll() throws
    func clearSent() throws
}
import SwiftData

public final class OfflineActionsSwiftDataSource: OfflineActionsDataSource {
    private let context: ModelContext

    public init(container: ModelContainer) {
        self.context = ModelContext(container)
    }

    public func enqueue(_ data: Data) throws {
        context.insert(OfflineActionEntity(payload: data))
        try context.save()
    }

    public func fetchPending(limit: Int = 50) throws -> [OfflineActionEntity] {
        var descriptor = FetchDescriptor<OfflineActionEntity>(
            predicate: #Predicate { $0.statusRaw == "pending" }
        )
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .forward)]
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    public func fetchAllPending() throws -> [OfflineActionEntity] {
        var descriptor = FetchDescriptor<OfflineActionEntity>(
            predicate: #Predicate { $0.statusRaw == "pending" }
        )
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .forward)]
        return try context.fetch(descriptor)
    }

    public func fetchFailed(limit: Int = 50) throws -> [OfflineActionEntity] {
        var descriptor = FetchDescriptor<OfflineActionEntity>(
            predicate: #Predicate { $0.statusRaw == "failed" }
        )
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .forward)]
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    public func replacePending(with payloads: [Data]) throws {
        let descriptor = FetchDescriptor<OfflineActionEntity>(
            predicate: #Predicate { $0.statusRaw == "pending" }
        )
        let pending = try context.fetch(descriptor)
        pending.forEach { context.delete($0) }
        for payload in payloads {
            context.insert(OfflineActionEntity(payload: payload))
        }
        try context.save()
    }

    public func markSent(id: String) throws {
        guard let entity = try fetchById(id) else { return }
        entity.statusRaw = "sent"
        entity.lastError = nil
        entity.lastAttemptAt = .now
        try context.save()
    }

    public func markFailed(id: String, error: String, retryable: Bool, attemptedAt: Date) throws {
        guard let entity = try fetchById(id) else { return }
        entity.statusRaw = retryable ? "failed" : "sent"
        entity.lastError = error
        entity.retryCount += 1
        entity.lastAttemptAt = attemptedAt
        try context.save()
    }

    public func delete(id: String) throws {
        guard let entity = try fetchById(id) else { return }
        context.delete(entity)
        try context.save()
    }

    public func clearAll() throws {
        let descriptor = FetchDescriptor<OfflineActionEntity>()
        let all = try context.fetch(descriptor)
        all.forEach { context.delete($0) }
        try context.save()
    }

    public func clearSent() throws {
        let descriptor = FetchDescriptor<OfflineActionEntity>(
            predicate: #Predicate { $0.statusRaw == "sent" }
        )
        let sent = try context.fetch(descriptor)
        sent.forEach { context.delete($0) }
        try context.save()
    }

    private func fetchById(_ id: String) throws -> OfflineActionEntity? {
        let descriptor = FetchDescriptor<OfflineActionEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }
}

