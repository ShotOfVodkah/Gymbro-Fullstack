import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject {

    private(set) var workouts: [WatchWorkoutPayload] = []

    override init() {
        super.init()
        activate()
        loadCachedWorkouts()
    }

    func submitSession(_ payload: WatchSessionPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        WCSession.default.transferUserInfo(["session": data])
    }

    // MARK: - Private

    private func activate() {
        guard WCSession.isSupported() else {
            return
        }
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
