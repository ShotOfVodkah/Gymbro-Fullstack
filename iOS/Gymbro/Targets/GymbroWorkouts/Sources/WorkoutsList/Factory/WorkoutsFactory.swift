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
        localMapper: WorkoutsLocalMapper
    ) -> some View  {
        guard let viewModelCache else {
            let workoutsNetworkClient = WorkoutsNetworkClientImpl()
            let viewModel = WorkoutsListViewModel(
                networkClient: workoutsNetworkClient,
                divLocalRepository: divLocalRepository,
                workoutsRepository: workoutsRepository,
                exercisesRepository: exercisesRepository,
                router: router,
                modelModifier: modelModifier,
                localMapper: localMapper
            )
            viewModelCache = viewModel
            return WorkoutsListView(viewModel: viewModel)
        }
        return WorkoutsListView(viewModel: viewModelCache)
    }
    
    private var viewModelCache: WorkoutsListViewModel?
}

