import Foundation
import SwiftUI
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

public final class FeedsChatFactoryImpl {
    
    private var viewModelCache: [ChatSessionInput: ChatViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: ChatSessionInput,
        router: any Router,
        client: FeedsClient,
        analytics: any AnalyticsService
    ) -> some View {
        if let cached = viewModelCache[input] {
            return ChatView(viewModel: cached)
        }
        
        let service = ChatServiceImpl(client: client)
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
