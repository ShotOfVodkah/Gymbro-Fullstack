import Foundation
import SwiftUI

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class ChallengeLeaderboardFactoryImpl {
    
    public init() {}
    
    @MainActor
    public func makeView(
        challengeID: String,
        router: any Router,
        client: any ChallengesClient,
        analytics: any AnalyticsService
    ) -> some View {
        let service = ChallengeLeaderboardServiceImpl(client: client)
        let viewModel = ChallengeLeaderboardViewModel(
            challengeID: challengeID,
            router: router,
            service: service,
            analytics: analytics
        )
        return ChallengeLeaderboardView(viewModel: viewModel)
    }
}
