import Combine
import Foundation
import Network

public protocol ConnectivityStatusProviding: AnyObject {
    var statusPublisher: AnyPublisher<Bool, Never> { get }
    var isOnline: Bool { get }
    func startMonitoring()
}

public final class NWPathConnectivityStatusProvider: ConnectivityStatusProviding {
    public var statusPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }

    public var isOnline: Bool {
        lock.lock()
        defer { lock.unlock() }
        return currentStatus
    }

    public init() {}

    public func startMonitoring() {
        lock.lock()
        guard !isMonitoring else {
            lock.unlock()
            return
        }
        isMonitoring = true
        lock.unlock()

        monitor.pathUpdateHandler = { [weak self] path in
            self?.handlePathUpdate(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "dev.tuist.gymbro.connectivity-monitor")
    private let subject = CurrentValueSubject<Bool, Never>(false)
    private let lock = NSLock()
    private var currentStatus = false
    private var isMonitoring = false

    private func handlePathUpdate(_ isOnline: Bool) {
        lock.lock()
        currentStatus = isOnline
        lock.unlock()
        subject.send(isOnline)
    }
}
