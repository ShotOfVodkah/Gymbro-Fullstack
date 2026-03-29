import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation

public final class WorkoutsListFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        divLocalRepository: DivCacheRepository,
        workoutsRepository: WorkoutsCacheRepository,
        exercisesRepository: ExercisesRepository,
        modelModifier: WorkoutsModelModifier,
        client: WorkoutsClient,
        localMapper: WorkoutsLocalMapper
    ) -> some View {
        guard let viewModelCache else {
            let service = WorkoutsListServiceImpl(
                networkClient: client,
                divLocalRepository: divLocalRepository,
                workoutsRepository: workoutsRepository,
                exercisesRepository: exercisesRepository,
                localMapper: localMapper
            )
            let viewModel = WorkoutsListViewModel(
                service: service,
                router: router,
                modelModifier: modelModifier
            )
            viewModelCache = viewModel
            return WorkoutsListView(viewModel: viewModel)
        }
        return WorkoutsListView(viewModel: viewModelCache)
    }

    private var viewModelCache: WorkoutsListViewModel?
}
