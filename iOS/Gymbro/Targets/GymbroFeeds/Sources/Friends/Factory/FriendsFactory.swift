import Foundation
import SwiftUI
import GymbroNavigation
import GymbroTypes
import GymbroNetwork

public final class FeedsPeopleFactoryImpl {
    
    private var viewModelCache: FeedsPeopleViewModel?
    
    public init() {}
    
    @MainActor
    public func makeView(
        router: any Router,
        client: FeedsClient,
        analytics: any AnalyticsService
    ) -> some View {
        guard let viewModelCache else {
            let service = FeedsPeopleServiceImpl(client: client)
            let viewModel = FeedsPeopleViewModel(
                router: router,
                service: service,
                analytics: analytics
            )
            self.viewModelCache = viewModel
            return FeedsPeopleView(viewModel: viewModel)
        }
        
        return FeedsPeopleView(viewModel: viewModelCache)
    }
}
