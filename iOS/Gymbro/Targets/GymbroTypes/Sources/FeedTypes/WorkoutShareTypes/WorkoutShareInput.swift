import Foundation

public struct WorkoutShareInput: Hashable {
    public let sessionID: String
    public let workoutID: String
    public let workoutName: String
    public let workoutType: String
    public let completedAt: Date

    public init(
        sessionID: String,
        workoutID: String,
        workoutName: String,
        workoutType: String,
        completedAt: Date
    ) {
        self.sessionID = sessionID
        self.workoutID = workoutID
        self.workoutName = workoutName
        self.workoutType = workoutType
        self.completedAt = completedAt
    }
}

extension WorkoutShareInput {
    public init(session: CompletedSession, workoutName: String, workoutType: WorkoutType) {
        self.init(
            sessionID: session.id,
            workoutID: session.workoutID,
            workoutName: workoutName,
            workoutType: workoutType.rawValue,
            completedAt: session.completedAt
        )
    }
}
