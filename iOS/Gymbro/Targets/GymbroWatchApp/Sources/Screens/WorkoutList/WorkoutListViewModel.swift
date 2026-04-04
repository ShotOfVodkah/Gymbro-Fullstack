import Foundation
import Combine

final class WorkoutListViewModel: ObservableObject {

    @Published private(set) var workouts: [WatchWorkoutPayload] = []

    private let connectivityManager: WatchConnectivityManager
    private var cancellables = Set<AnyCancellable>()

    init(connectivityManager: WatchConnectivityManager) {
        self.connectivityManager = connectivityManager
        connectivityManager.$workouts
            .receive(on: DispatchQueue.main)
            .assign(to: &$workouts)
    }

    func submitSession(_ payload: WatchSessionPayload) {
        connectivityManager.submitSession(payload)
    }
}
