import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation
import GymbroTypes

public final class FeedsMainTabFactoryImpl {

    private var viewModelCache: FeedsMainTabViewModel?

    public init() {}

    @MainActor
    public func makeView(router: any Router, analytics: any AnalyticsService) -> some View {
        guard let viewModelCache else {
            let viewModel = FeedsMainTabViewModel(router: router, analytics: analytics)
            self.viewModelCache = viewModel
            return FeedsMainTabView(viewModel: viewModel)
        }
        return FeedsMainTabView(viewModel: viewModelCache)
    }
}
