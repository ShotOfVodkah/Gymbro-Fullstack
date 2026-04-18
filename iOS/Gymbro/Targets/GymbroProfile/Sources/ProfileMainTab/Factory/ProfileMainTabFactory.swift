import Foundation
import SwiftUI

import GymbroNavigation
import GymbroTypes

public final class ProfileMainTabFactoryImpl {
    
    private var viewModelCache: [ProfileViewMode: ProfileMainTabViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        router: any Router,
        mode: ProfileViewMode,
        gateway: any ProfileGateway,
        analytics: any AnalyticsService
    ) -> some View {
        if let cachedViewModel = viewModelCache[mode] {
            return ProfileMainTabView(viewModel: cachedViewModel)
        }
        
        let service = ProfileMainServiceImpl(gateway: gateway)
        let viewModel = ProfileMainTabViewModel(
            router: router,
            mode: mode,
            service: service,
            analytics: analytics
        )
        viewModelCache[mode] = viewModel
        
        return ProfileMainTabView(viewModel: viewModel)
    }
}
