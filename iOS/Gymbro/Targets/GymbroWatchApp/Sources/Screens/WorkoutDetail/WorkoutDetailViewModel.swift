import Foundation

final class WorkoutDetailViewModel: ObservableObject {

    init(workout: WatchWorkoutPayload, onSubmit: @escaping (WatchSessionPayload) -> Void) {
        self.workout = workout
        self.onSubmit = onSubmit
    }

    func makePlayerViewModel() -> WorkoutPlayerViewModel {
        WorkoutPlayerViewModel(workout: workout, onSubmit: onSubmit)
    }
    
    let workout: WatchWorkoutPayload
    private let onSubmit: (WatchSessionPayload) -> Void
    
}
