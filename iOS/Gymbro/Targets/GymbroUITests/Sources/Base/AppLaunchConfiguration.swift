import Foundation

enum AppLaunchArgument {
    static let uiTesting = "-ui-testing"
    static let resetState = "-reset-state"
    static let mockNetwork = "-mock-network"
    static let authorizedUser = "-authorized-user"
}

struct AppLaunchConfiguration {
    var resetState: Bool = true
    var mockNetwork: Bool = true
    var authorizedUser: Bool = true

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

        return arguments
    }
}
