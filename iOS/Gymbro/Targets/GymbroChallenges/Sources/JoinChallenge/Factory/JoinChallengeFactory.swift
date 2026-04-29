import Foundation
import SwiftUI

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class JoinChallengeFactoryImpl {
    
    public init() {}
    
    @MainActor
    public func makeView(
        challengeID: String,
        router: any Router,
        client: any ChallengesClient,
        analytics: any AnalyticsService
    ) -> some View {
        let service = JoinChallengeServiceImpl(client: client)
        let viewModel = JoinChallengeViewModel(
            challengeID: challengeID,
            router: router,
            service: service,
            analytics: analytics
        )
        return JoinChallengeView(viewModel: viewModel)
    }
}
