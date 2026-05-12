import Foundation
import SwiftUI

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class ChallengeDetailsFactoryImpl {
    
    public init() {}
    
    @MainActor
    public func makeView(
        challengeID: String,
        router: any Router,
        client: any ChallengesClient,
        feedsClient: any FeedsClientProtocol,
        analytics: any AnalyticsService
    ) -> some View {
        let service = ChallengeDetailsServiceImpl(client: client)
        let viewModel = ChallengeDetailsViewModel(
            challengeID: challengeID,
            router: router,
            service: service,
            analytics: analytics,
            feedsClient: feedsClient
        )
        return ChallengeDetailsView(viewModel: viewModel)
    }
}
