import Foundation
import DivKit

enum WorkoutsNavigationLink {
    case openWorkout(id: String)
    case openBuilder
    case openStreak(current: Int, goal: Int, daysLeft: Int, value: Int)
}

enum WorkoutInfoNavigationLink {
    case openPlayer(id: String)
    case delete(id: String)
    case edit(id: String)
}

final class NoopDivUrlHandler: DivUrlHandler {
    func handle(_ url: URL, sender: AnyObject?) { }
}
