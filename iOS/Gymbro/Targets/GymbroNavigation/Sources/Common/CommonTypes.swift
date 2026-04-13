import Foundation
import SwiftUI

import GymbroTypes

public protocol NavigationDestination {
    var route: NavigationRoute { get }
    func makeView() -> any View
}

public enum NavigationRoute: Hashable {
    case workoutInfo(id: String)
    case workoutPlayer(id: String)
    case workoutBuilder
    case workoutBuilderForType(type: String?, workoutId: String?)
    case workoutGenerator
    
    case feedsPeople
    case feedsProfile(title: String)
    case feedsCalendar(context: CalendarContext)
    case feedsChat(input: ChatSessionInput)
    
    // другие маршруты
}

public protocol Router: ObservableObject {
    func navigate(to route: NavigationRoute)
    func pop()
    func popToRoot()
}
