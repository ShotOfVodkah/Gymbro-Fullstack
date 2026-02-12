import Combine

public enum WorkoutEvent {
    case workoutDeleted
}

public final class WorkoutsModelModifier {
    let events = PassthroughSubject<WorkoutEvent, Never> ()
    
    public init() {}
}
