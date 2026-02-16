import Combine

public enum WorkoutEvent {
    case workoutDeleted
    case premadeWorkoutAdded(id: String)
}

public final class WorkoutsModelModifier {
    let events = PassthroughSubject<WorkoutEvent, Never> ()
    
    public init() {}
}
