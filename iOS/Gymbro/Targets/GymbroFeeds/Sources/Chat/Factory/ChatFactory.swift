import Foundation
import SwiftUI
import GymbroNavigation
import GymbroTypes

public final class FeedsChatFactoryImpl {
    
    private var viewModelCache: [ChatSessionInput: ChatViewModel] = [:]
    
    public init() {}
    
    @MainActor
    public func makeView(
        input: ChatSessionInput,
        router: any Router
    ) -> some View {
        if let cached = viewModelCache[input] {
            return ChatView(viewModel: cached)
        } else {
            let viewModel = ChatViewModel(input: input, router: router)
            viewModelCache[input] = viewModel
            return ChatView(viewModel: viewModel)
        }
    }
}
