import Foundation
import SwiftUI
import GymbroNavigation
import GymbroTypes
import GymbroNetwork

public final class FeedsPeopleFactoryImpl {
    
    private var viewModelCache: [PeopleScreenInput: FeedsPeopleViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: PeopleScreenInput,
        router: any Router,
        client: FeedsClient,
        analytics: any AnalyticsService
    ) -> some View {
        if let cached = viewModelCache[input] {
            return FeedsPeopleView(viewModel: cached)
        }
        
        let service = FeedsPeopleServiceImpl(client: client)
        let viewModel = FeedsPeopleViewModel(
            input: input,
            router: router,
            service: service,
            analytics: analytics
        )
        
        viewModelCache[input] = viewModel
        return FeedsPeopleView(viewModel: viewModel)
    }
}
