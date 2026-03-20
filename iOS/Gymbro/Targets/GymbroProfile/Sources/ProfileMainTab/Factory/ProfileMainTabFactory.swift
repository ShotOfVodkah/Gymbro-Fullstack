import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation

public final class ProfileMainTabFactoryImpl {

    public init() {}

    @MainActor
    public func makeView() -> some View  {
        guard let viewModelCache else {
            let viewModel = ProfileMainTabViewModel()
            viewModelCache = viewModel
            return ProfileMainTabView(viewModel: viewModel)
        }
        return ProfileMainTabView(viewModel: viewModelCache)
    }
    
    private var viewModelCache: ProfileMainTabViewModel?
}
