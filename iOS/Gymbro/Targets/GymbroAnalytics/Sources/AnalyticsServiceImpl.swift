import Foundation
import GymbroTypes
import GymbroNetwork

public final class AnalyticsServiceImpl: AnalyticsService {
    private let client: AnalyticsClient
    private let sessionId: String
    private let lock = NSLock()
    private var _buffer: [AnalyticsEventDTO] = []
    private let bufferLimit = 20
    private var flushTask: Task<Void, Never>?

    public init(client: AnalyticsClient) {
        self.client = client
        self.sessionId = UUID().uuidString
        schedulePeriodicFlush()
    }

    public func track(_ event: AnalyticsEvent) {
        guard let userId = AppMicroservices.tokens.userId, !userId.isEmpty else { return }
        let sessionId = lock.withLock { self.sessionId }
        let dto = event.toDTO(sessionId: sessionId, userId: userId)
        let shouldFlush = lock.withLock { () -> Bool in
            _buffer.append(dto)
            return _buffer.count >= bufferLimit
        }
        if shouldFlush {
            flush()
        }
    }

    public func flush() {
        let batch = lock.withLock { () -> [AnalyticsEventDTO] in
            guard !_buffer.isEmpty else { return [] }
            let b = _buffer
            _buffer = []
            return b
        }
        guard !batch.isEmpty else { return }
        Task {
            await send(batch)
        }
    }

    private func send(_ batch: [AnalyticsEventDTO]) async {
        do {
            try await client.sendBatch(batch)
        } catch {
            lock.withLock { _buffer.insert(contentsOf: batch, at: 0) }
        }
    }

    private func schedulePeriodicFlush() {
        flushTask?.cancel()
        flushTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                self?.flush()
            }
        }
    }

    deinit {
        flushTask?.cancel()
    }
}
