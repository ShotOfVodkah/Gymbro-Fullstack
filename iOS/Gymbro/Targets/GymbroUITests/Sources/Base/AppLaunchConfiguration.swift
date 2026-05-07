import Foundation

enum AppLaunchArgument {
    static let uiTesting = "-ui-testing"
    static let resetState = "-reset-state"
    static let mockNetwork = "-mock-network"
    static let authorizedUser = "-authorized-user"
    static let uitestRouteWorkoutShare = "-uitest-route-workout-share"

    static let uitestPerksStreakCompleted = "-uitest-perks-streak-completed"
    static let uitestPerksStreakFreeze = "-uitest-perks-streak-freeze"
    static let uitestPerksStreakDanger = "-uitest-perks-streak-danger"

    static let uitestChallengesUnavailableTeams = "-uitest-challenges-unavailable-teams"

    static let uitestWorkoutsPlayerOffline = "-uitest-workouts-player-offline"
}

enum PerksStreakUITestVariant {
    case standard
    case completed
    case freezeActive
    case dangerWindow
}

struct AppLaunchConfiguration {
    var resetState: Bool = true
    var mockNetwork: Bool = true
    var authorizedUser: Bool = true
    var openWorkoutShareRoute: Bool = false
    var perksStreakVariant: PerksStreakUITestVariant = .standard
    var challengesUnavailableTeams: Bool = false
    var workoutsPlayerOffline: Bool = false

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

        switch perksStreakVariant {
        case .standard:
            break
        case .completed:
            arguments.append(AppLaunchArgument.uitestPerksStreakCompleted)
        case .freezeActive:
            arguments.append(AppLaunchArgument.uitestPerksStreakFreeze)
        case .dangerWindow:
            arguments.append(AppLaunchArgument.uitestPerksStreakDanger)
        }

        if challengesUnavailableTeams {
            arguments.append(AppLaunchArgument.uitestChallengesUnavailableTeams)
        }

        if workoutsPlayerOffline {
            arguments.append(AppLaunchArgument.uitestWorkoutsPlayerOffline)
        }

        return arguments
    }
}
