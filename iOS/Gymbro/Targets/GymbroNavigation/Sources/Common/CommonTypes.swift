import Foundation
import SwiftUI

import GymbroTypes

public protocol NavigationDestination {
    var route: NavigationRoute { get }
    func makeView() -> any View
}

public enum NavigationRoute: Hashable {
    case workoutInfo(id: String, type: WorkoutInfoType)
    case workoutPlayer(id: String)
    case workoutBuilder
    case workoutBuilderForType(type: String?, workoutId: String?)
    case workoutGenerator
    
    case feedsPeople
    case feedsCalendar(context: CalendarContext)
    case feedsChat(input: ChatSessionInput)
    
    case profileMain(mode: ProfileViewMode)
    case profileEdit
    case profileSettings
    case profileStatistics(mode: ProfileViewMode)
    case profilePosts(userID: Int, userName: String)
    
    // другие маршруты
}

public protocol Router: ObservableObject {
    func navigate(to route: NavigationRoute)
    func pop()
    func popToRoot()
}
