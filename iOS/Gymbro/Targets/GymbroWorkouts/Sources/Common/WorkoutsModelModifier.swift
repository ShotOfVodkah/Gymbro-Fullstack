import Combine
import GymbroTypes

public enum WorkoutEvent {
    case statusChanged(status: OfflineStatus)
    case forceReload
    case workoutDeleted(id: String)
    case premadeWorkoutAdded(id: String)
    case workoutAdded(id: String)
    case workoutEdited(id: String)
}

public final class WorkoutsModelModifier {
    let events = PassthroughSubject<WorkoutEvent, Never> ()
    
    public init() {}
}
