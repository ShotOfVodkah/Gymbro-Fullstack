import Foundation
import SwiftUI
import GymbroNavigation

public final class AppRouter: Router {
    @Published public var path: [NavigationRoute] = []
    
    public func navigate(to route: NavigationRoute) {
        path.append(route)
    }
    
    public func pop() {
        _ = path.popLast()
    }
}
