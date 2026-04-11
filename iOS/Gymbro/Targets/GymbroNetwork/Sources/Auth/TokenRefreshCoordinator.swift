import Foundation

actor TokenRefreshCoordinator {
    private var refreshTask: Task<Bool, Error>?
    
    func refreshIfNeeded(
        operation: @escaping @Sendable () async throws -> Bool
    ) async throws -> Bool {
        if let existingTask = refreshTask {
            return try await existingTask.value
        }
        
        let task = Task {
            try await operation()
        }
        
        refreshTask = task
        
        do {
            let result = try await task.value
            refreshTask = nil
            return result
        } catch {
            refreshTask = nil
            throw error
        }
    }
}
