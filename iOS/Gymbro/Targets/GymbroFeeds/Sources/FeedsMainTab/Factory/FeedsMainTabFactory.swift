import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation

public final class FeedsMainTabFactoryImpl {

    private var viewModelCache: FeedsMainTabViewModel?

    public init() {}

    @MainActor
    public func makeView(router: any Router) -> some View {
        guard let viewModelCache else {
            let viewModel = FeedsMainTabViewModel(router: router)
            self.viewModelCache = viewModel
            return FeedsMainTabView(viewModel: viewModel)
        }
        return FeedsMainTabView(viewModel: viewModelCache)
    }
}
