import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation
import GymbroTypes

public final class ProfileMainTabFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(analytics: any AnalyticsService) -> some View  {
        guard let viewModelCache else {
            let viewModel = ProfileMainTabViewModel(analytics: analytics)
            viewModelCache = viewModel
            return ProfileMainTabView(viewModel: viewModel)
        }
        return ProfileMainTabView(viewModel: viewModelCache)
    }
    
    private var viewModelCache: ProfileMainTabViewModel?
}
