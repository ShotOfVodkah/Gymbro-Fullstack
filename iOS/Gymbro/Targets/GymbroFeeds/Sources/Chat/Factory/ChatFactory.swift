import Foundation
import SwiftUI
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class FeedsChatFactoryImpl {
    
    private var cachedUserID: String?
    private var viewModelCache: [ChatSessionInput: ChatViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: ChatSessionInput,
        router: any Router,
        client: FeedsClient,
        realtimeClient: FeedsChatRealtimeClient,
        analytics: any AnalyticsService
    ) -> some View {
        let currentUserID = AppMicroservices.tokens.userId ?? ""
        
        if cachedUserID != currentUserID {
            viewModelCache.removeAll()
            cachedUserID = currentUserID
            FeedsStateInvalidationCenter.shared.invalidate(.accountChanged)
        }
        
        if let cached = viewModelCache[input] {
            return ChatView(viewModel: cached)
        }
        
        let service = ChatServiceImpl(client: client, realtimeClient: realtimeClient)
        let viewModel = ChatViewModel(
            input: input,
            router: router,
            service: service,
            analytics: analytics
        )
        viewModelCache[input] = viewModel
        
        return ChatView(viewModel: viewModel)
    }
}
