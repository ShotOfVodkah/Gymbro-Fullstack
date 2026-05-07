import Foundation
import SwiftUI
import GymbroNavigation
import GymbroTypes
import GymbroNetwork

public final class FeedsPeopleFactoryImpl {
    
    private var cachedUserID: String?
    private var viewModelCache: [PeopleScreenInput: FeedsPeopleViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: PeopleScreenInput,
        router: any Router,
        client: any FeedsClientProtocol,
        analytics: any AnalyticsService
    ) -> some View {
        let currentUserID = AppMicroservices.tokens.userId ?? ""

        if cachedUserID != currentUserID {
            viewModelCache.removeAll()
            cachedUserID = currentUserID
            FeedsStateInvalidationCenter.shared.invalidate(.accountChanged)
        }
        
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
