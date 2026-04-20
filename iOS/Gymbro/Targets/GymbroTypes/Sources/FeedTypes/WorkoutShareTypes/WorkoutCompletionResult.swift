import Foundation

public enum WorkoutCompletionResult {
    case completed(session: CompletedSession)
    case queuedOffline
}

public enum WorkoutFinishAction {
    case saveOnly
    case shareWorkout
}

public enum WorkoutShareStep {
    case recipients
    case details
    case preview
}
