import Foundation
import SwiftUI

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class PerksMainTabFactoryImpl {
    
    private var viewModelCache: PerksMainTabViewModel?
    
    public init() {}
    
    @MainActor
    public func makeView(
        router: any Router,
        client: any PerksClient,
        analytics: any AnalyticsService
    ) -> some View {
        guard let viewModelCache else {
            let service = PerksMainTabServiceImpl(client: client)
            let viewModel = PerksMainTabViewModel(
                router: router,
                service: service,
                analytics: analytics
            )
            self.viewModelCache = viewModel
            return PerksMainTabView(viewModel: viewModel)
        }
        
        return PerksMainTabView(viewModel: viewModelCache)
    }
}
