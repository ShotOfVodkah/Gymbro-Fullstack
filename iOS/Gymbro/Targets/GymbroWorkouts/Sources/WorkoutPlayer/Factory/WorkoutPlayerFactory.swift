import Foundation
import SwiftUI

import GymbroNavigation
import GymbroNetwork

public final class WorkoutPlayerFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        id: String,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        workoutsRepository: WorkoutsCacheRepository,
        actionsRepository: OfflineActionsRepository,
        client: WorkoutsClient
    ) -> some View {
        guard let viewModelCache, id == idCache else {
            let service = WorkoutPlayerServiceImpl(
                client: client,
                workoutsRepository: workoutsRepository,
                actionsRepository: actionsRepository
            )
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
