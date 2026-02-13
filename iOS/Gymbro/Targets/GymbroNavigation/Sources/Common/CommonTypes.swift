import Foundation
import SwiftUI

public protocol NavigationDestination {
    var route: NavigationRoute { get }
    func makeView() -> any View
}

public enum NavigationRoute: Hashable {
    case workoutInfo(id: String)
    case workoutBuilder
    // другие маршруты
}

public protocol Router: ObservableObject {
    func navigate(to route: NavigationRoute)
    func pop()
}
