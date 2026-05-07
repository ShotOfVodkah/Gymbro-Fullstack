import Foundation
import SwiftUI
import GymbroNetwork
import GymbroNavigation
import GymbroTypes

public final class ProfileStatisticsFactoryImpl {
    
    private var viewModelCache: [ProfileViewMode: ProfileStatisticsViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        mode: ProfileViewMode,
        router: any Router,
        client: any ProfileClientProtocol,
        analytics: any AnalyticsService
    ) -> some View {
        if let cached = viewModelCache[mode] {
            return ProfileStatisticsView(viewModel: cached)
        }
        
        let service = ProfileStatisticsService(client: client)
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
