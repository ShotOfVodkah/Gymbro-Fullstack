import Foundation
import SwiftUI
import GymbroNavigation
import GymbroTypes

public final class ProfileStatisticsFactoryImpl {
    
    private var viewModelCache: [ProfileViewMode: ProfileStatisticsViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        mode: ProfileViewMode,
        router: any Router,
        analytics: any AnalyticsService
    ) -> some View {
        if let cachedViewModel = viewModelCache[mode] {
            return ProfileStatisticsView(viewModel: cachedViewModel)
        }
        
        let service = ProfileStatisticsService()
        let viewModel = ProfileStatisticsViewModel(
            mode: mode,
            service: service,
            router: router,
            analytics: analytics
        )
        
        viewModelCache[mode] = viewModel
        
        return ProfileStatisticsView(viewModel: viewModel)
    }
}
