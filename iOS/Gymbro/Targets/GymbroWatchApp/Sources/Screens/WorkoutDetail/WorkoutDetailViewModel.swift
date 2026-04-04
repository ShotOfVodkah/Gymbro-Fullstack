import Foundation

final class WorkoutDetailViewModel: ObservableObject {

    let workout: WatchWorkoutPayload
    private let onSubmit: (WatchSessionPayload) -> Void

    init(workout: WatchWorkoutPayload, onSubmit: @escaping (WatchSessionPayload) -> Void) {
        self.workout = workout
        self.onSubmit = onSubmit
    }

    func makePlayerViewModel() -> WorkoutPlayerViewModel {
        WorkoutPlayerViewModel(workout: workout, onSubmit: onSubmit)
    }
}
