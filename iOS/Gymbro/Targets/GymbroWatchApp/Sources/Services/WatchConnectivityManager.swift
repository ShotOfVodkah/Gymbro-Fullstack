import Foundation
import Combine
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {

    @Published private(set) var workouts: [WatchWorkoutPayload] = []

    override init() {
        super.init()
        activate()
        loadCachedWorkouts()
    }

    func submitSession(_ payload: WatchSessionPayload) {
        let session = WCSession.default
        guard session.activationState == .activated,
              let data = try? JSONEncoder().encode(payload) else {
            return
        }
        if session.isReachable {
            session.sendMessage(
                ["session": data],
                replyHandler: { _ in },
                errorHandler: { _ in
                    session.transferUserInfo(["session": data])
                }
            )
        } else {
            session.transferUserInfo(["session": data])
        }
    }

    // MARK: - Private

    private func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func loadCachedWorkouts() {
        let context = WCSession.default.receivedApplicationContext
        updateWorkouts(from: context)
    }

    private func updateWorkouts(from context: [String: Any]) {
        guard let data = context["workouts"] as? Data else { return }
        do {
            let decoded = try JSONDecoder().decode([WatchWorkoutPayload].self, from: data)
            workouts = decoded
        } catch {
            print("Failed to decode workouts: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated else { return }
        loadCachedWorkouts()
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.updateWorkouts(from: applicationContext)
        }
    }
}
