import Foundation
import SwiftUI

import GymbroNavigation

public final class WorkoutPlayerFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        id: String,
        router: any Router
    ) -> some View {
        guard let viewModelCache, id == idCache else {
            let viewModel = WorkoutPlayerViewModel(id: id, router: router)
            viewModelCache = viewModel
            idCache = id
            return WorkoutPlayerView(viewModel: viewModel)
        }
        return WorkoutPlayerView(viewModel: viewModelCache)
    }

    private var idCache: String?
    private var viewModelCache: WorkoutPlayerViewModel?
}
