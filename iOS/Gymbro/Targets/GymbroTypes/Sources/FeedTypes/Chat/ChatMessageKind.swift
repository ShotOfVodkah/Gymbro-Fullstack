import Foundation

public enum ChatMessageKind: Hashable {
    case text(String)
    case workout(
        workoutID: String,
        title: String,
        subtitle: String,
        duration: String,
        category: String
    )
}
