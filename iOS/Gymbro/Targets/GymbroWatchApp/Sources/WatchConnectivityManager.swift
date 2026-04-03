import Foundation
import WatchConnectivity

//@Observable
final class WatchConnectivityManager: NSObject {

//    private(set) var workouts: [WatchWorkoutPayload] = []

    override init() {
        super.init()
        activate()
        loadCachedWorkouts()
    }

//    func submitSession(_ payload: WatchSessionPayload) {
//        guard let data = try? JSONEncoder().encode(payload) else { return }
//        WCSession.default.transferUserInfo(["session": data])
//    }

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
        guard let data = context["workouts"] as? String else {
//              let decoded = try? JSONDecoder().decode([WatchWorkoutPayload].self, from: data) else {
//            let decoded = try? JSONDecoder().decode(String.self, from: data) else {
            print(context["workouts"])
            return
        }
        print(data)
//        workouts = decoded
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
