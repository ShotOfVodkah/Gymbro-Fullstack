import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation
import GymbroTypes

public final class FeedsMainTabFactoryImpl {

    private var viewModelCache: FeedsMainTabViewModel?

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        client: FeedsClient,
        analytics: any AnalyticsService
    ) -> some View {
        guard let viewModelCache else {
            let service = FeedsMainTabServiceImpl(client: client)
            let viewModel = FeedsMainTabViewModel(
                router: router,
                service: service,
                analytics: analytics
            )
            self.viewModelCache = viewModel
            return FeedsMainTabView(viewModel: viewModel)
        }
        
        return FeedsMainTabView(viewModel: viewModelCache)
    }
}
