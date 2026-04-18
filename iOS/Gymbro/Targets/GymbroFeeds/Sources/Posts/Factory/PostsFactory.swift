import Foundation
import SwiftUI
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class FeedsProfilePostsFactoryImpl {
    
    private var viewModelCache: [PostsScreenInput: FeedsProfilePostsViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: PostsScreenInput,
        router: any Router,
        client: FeedsClient,
        analytics: any AnalyticsService
    ) -> some View {
        if let cached = viewModelCache[input] {
            return FeedsProfilePostsView(viewModel: cached)
        }
        
        let service = FeedsProfilePostsServiceImpl(client: client)
        let viewModel = FeedsProfilePostsViewModel(
            input: input,
            router: router,
            service: service,
            analytics: analytics
        )
        
        viewModelCache[input] = viewModel
        return FeedsProfilePostsView(viewModel: viewModel)
    }
}
