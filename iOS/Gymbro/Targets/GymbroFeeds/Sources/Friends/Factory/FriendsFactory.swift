import Foundation
import SwiftUI
import GymbroNavigation

public final class FeedsPeopleFactoryImpl {
    
    private var viewModelCache: FeedsPeopleViewModel?
    
    public init() {}
    
    @MainActor
    public func makeView(router: any Router) -> some View {
        guard let viewModelCache else {
            let viewModel = FeedsPeopleViewModel(router: router)
            self.viewModelCache = viewModel
            return FeedsPeopleView(viewModel: viewModel)
        }
        return FeedsPeopleView(viewModel: viewModelCache)
    }
}
