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
    
    case feedsPeople
    case feedsProfile(title: String)
    case feedsCalendar(context: CalendarContext)
    case feedsChat(input: ChatSessionInput)
    
    // change
    case feedsPost(title: String)
    case feedsComments(title: String)
    case feedsExercise(title: String)
    
    // другие маршруты
}

public enum CalendarContext: Hashable {
    case mine
    case person(personID: String, personName: String)
    case directChat(chatID: String, participantIDs: [String], initialPersonID: String?)
    case groupChat(chatID: String, groupID: String, initialPersonID: String?)
}

public protocol Router: ObservableObject {
    func navigate(to route: NavigationRoute)
    func pop()
    func popToRoot()
}
