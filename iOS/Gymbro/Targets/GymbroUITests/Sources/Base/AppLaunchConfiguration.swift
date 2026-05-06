import Foundation

enum AppLaunchArgument {
    static let uiTesting = "-ui-testing"
    static let resetState = "-reset-state"
    static let mockNetwork = "-mock-network"
    static let authorizedUser = "-authorized-user"
    static let uitestRouteWorkoutShare = "-uitest-route-workout-share"
}

struct AppLaunchConfiguration {
    var resetState: Bool = true
    var mockNetwork: Bool = true
    var authorizedUser: Bool = true
    var openWorkoutShareRoute: Bool = false

    var launchArguments: [String] {
        var arguments = [AppLaunchArgument.uiTesting]

        if resetState {
            arguments.append(AppLaunchArgument.resetState)
        }

        if mockNetwork {
            arguments.append(AppLaunchArgument.mockNetwork)
        }

        if authorizedUser {
            arguments.append(AppLaunchArgument.authorizedUser)
        }

        if openWorkoutShareRoute {
            arguments.append(AppLaunchArgument.uitestRouteWorkoutShare)
        }

        return arguments
    }
}
