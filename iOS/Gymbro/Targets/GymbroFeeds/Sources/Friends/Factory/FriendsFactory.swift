import Foundation
import SwiftUI
import GymbroNavigation
import GymbroTypes

public final class FeedsPeopleFactoryImpl {
    
    private var viewModelCache: FeedsPeopleViewModel?
    
    public init() {}
    
    @MainActor
    public func makeView(router: any Router, analytics: any AnalyticsService) -> some View {
        guard let viewModelCache else {
            let viewModel = FeedsPeopleViewModel(router: router, analytics: analytics)
            self.viewModelCache = viewModel
            return FeedsPeopleView(viewModel: viewModel)
        }
        return FeedsPeopleView(viewModel: viewModelCache)
    }
}
