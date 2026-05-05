import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation
import GymbroTypes

public final class ProfileSettingsFactoryImpl {
    
    private var viewModelCache: ProfileSettingsViewModel?
    
    public init() {}
    
    @MainActor
    public func makeView(
        router: any Router,
        client: any ProfileClientProtocol,
        analytics: any AnalyticsService
    ) -> some View {
        if let viewModelCache {
            return ProfileSettingsView(viewModel: viewModelCache)
        }
        
        let service = SettingsService(client: client)
        let viewModel = ProfileSettingsViewModel(
            router: router,
            service: service,
            analytics: analytics
        )
        
        self.viewModelCache = viewModel
        return ProfileSettingsView(viewModel: viewModel)
    }
}
