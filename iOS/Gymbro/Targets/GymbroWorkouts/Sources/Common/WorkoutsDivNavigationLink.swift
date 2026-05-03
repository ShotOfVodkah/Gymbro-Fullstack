import Foundation
import DivKit

import GymbroTypes

enum WorkoutsNavigationLink {
    case openWorkout(id: String)
    case openBuilder
    case openStreak(
        current: Int,
        goal: Int,
        daysLeft: Int,
        value: Int,
        wasFreezeUsedThisWeek: Bool,
        isGoalCompleted: Bool
    )
}

enum WorkoutInfoNavigationLink {
    case openPlayer(id: String)
    case delete(id: String)
    case addToMy(id: String)
    case edit(id: String)
}

enum WorkoutBuilderTitleNavigationLink {
    case savePremade(id: String)
    case openPremade(id: String)
    case openBuilder(type: String)
    case openAI
}

enum WorkoutBuilderForTypeNavigationLink {
    case add(id: String)
    case remove(id: String)
}

final class NoopDivUrlHandler: DivUrlHandler {
    func handle(_ url: URL, sender: AnyObject?) { }
}
