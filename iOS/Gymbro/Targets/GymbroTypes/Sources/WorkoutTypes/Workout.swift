import Foundation

public struct Workout {
    public let id: String
    public let name: String
    public let type: WorkoutType
    public let exercises: [Exercise]
    
    public init(
        id: String,
        name: String,
        type: WorkoutType,
        exercises: [Exercise]
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.exercises = exercises
    }
}
