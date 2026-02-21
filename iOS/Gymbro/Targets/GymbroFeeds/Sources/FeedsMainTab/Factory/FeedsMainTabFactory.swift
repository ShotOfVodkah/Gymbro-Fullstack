import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation

public final class FeedsMainTabFactoryImpl {

    public init() {}

    @MainActor
    public func makeView() -> some View  {
        guard let viewModelCache else {
            let viewModel = FeedsMainTabViewModel()
            viewModelCache = viewModel
            return FeedsMainTabView(viewModel: viewModel)
        }
        return FeedsMainTabView(viewModel: viewModelCache)
    }
    
    private var viewModelCache: FeedsMainTabViewModel?
}
