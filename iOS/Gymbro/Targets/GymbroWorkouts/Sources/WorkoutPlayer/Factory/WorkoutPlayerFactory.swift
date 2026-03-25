import Foundation
import SwiftUI

import GymbroNavigation

public final class WorkoutPlayerFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        id: String,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
    ) -> some View {
        guard let viewModelCache, id == idCache else {
            let service = WorkoutPlayerServiceImpl()
            let viewModel = WorkoutPlayerViewModel(id: id, router: router, modelModifier: modelModifier, service: service)
            viewModelCache = viewModel
            idCache = id
            return WorkoutPlayerView(viewModel: viewModel)
        }
        return WorkoutPlayerView(viewModel: viewModelCache)
    }

    private var idCache: String?
    private var viewModelCache: WorkoutPlayerViewModel?
}
