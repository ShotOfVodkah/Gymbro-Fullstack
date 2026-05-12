import Foundation
import SwiftUI

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class ChallengesMainTabFactoryImpl {

    private var cachedUserID: String?
    private var viewModelCache: ChallengesMainTabViewModel?

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        client: any ChallengesClient,
        analytics: any AnalyticsService
    ) -> some View {
        let currentUserID = AppMicroservices.tokens.userId ?? ""

        if cachedUserID != currentUserID {
            viewModelCache = nil
            cachedUserID = currentUserID
        }

        guard let viewModelCache else {
            let service = ChallengesMainTabServiceImpl(client: client)
            let viewModel = ChallengesMainTabViewModel(
                router: router,
                service: service,
                analytics: analytics
            )
            self.viewModelCache = viewModel
            return ChallengesMainTabView(viewModel: viewModel)
        }

        return ChallengesMainTabView(viewModel: viewModelCache)
    }
}
