import Foundation
import GymbroNetwork

struct AppClients {
    let feeds: any FeedsClientProtocol
    let workouts: any WorkoutsClientProtocol
    let profile: any ProfileClientProtocol
    let perks: any PerksClient
    let challenges: any ChallengesClient
    let auth: any AuthServiceProtocol

    static var real: AppClients {
        NSLog("🌍 USING REAL CLIENTS")
        return AppClients(
            feeds: AppMicroservices.feeds,
            workouts: AppMicroservices.workouts,
            profile: AppMicroservices.profile,
            perks: AppMicroservices.perks,
            challenges: AppMicroservices.challenges,
            auth: AppMicroservices.auth
        )
    }

    static var mock: AppClients {
        NSLog("🔥 USING MOCK CLIENTS")
        return AppClients(
            feeds: MockFeedsClient(),
            workouts: MockWorkoutsClient(),
            profile: MockProfileClient(),
            perks: MockPerksClient(),
            challenges: MockChallengesClient(),
            auth: MockAuthService()
        )
    }
}
