import Foundation

enum AppEnvironment {

    static let arguments = ProcessInfo.processInfo.arguments

    static var isUITesting: Bool {
        arguments.contains("-ui-testing")
    }

    static var shouldResetState: Bool {
        arguments.contains("-reset-state")
    }

    static var shouldUseMockNetwork: Bool {
        arguments.contains("-mock-network")
    }

    static var shouldAuthorizeUser: Bool {
        arguments.contains("-authorized-user")
    }

    static var shouldDisableStartupServices: Bool {
        isUITesting
    }
}
