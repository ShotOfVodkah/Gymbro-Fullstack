import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation

public final class WorkoutBuilderForTypeFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        divLocalRepository: DivCacheRepository,
        workoutsRepository: WorkoutsCacheRepository,
        exercisesRepository: ExercisesRepository,
        actionsRepository: OfflineActionsRepository,
        modelModifier: WorkoutsModelModifier,
        type: String?,
        workoutId: String?
    ) -> some View  {
        guard let viewModelCache, typeCache == type, idCache == workoutId else {
            let workoutsNetworkClient = WorkoutsNetworkClientImpl()
            let viewModel = WorkoutBuilderForTypeViewModel(
                networkClient: workoutsNetworkClient,
                router: router,
                divLocalRepository: divLocalRepository,
                workoutsRepository: workoutsRepository,
                exercisesRepository: exercisesRepository,
                actionsRepository: actionsRepository,
                modelModifier: modelModifier,
                type: type,
                workoutId: workoutId
            )
            viewModelCache = viewModel
            typeCache = type
            idCache = workoutId
            return WorkoutBuilderForTypeView(viewModel: viewModel)
        }
        return WorkoutBuilderForTypeView(viewModel: viewModelCache)
    }
    
    private var viewModelCache: WorkoutBuilderForTypeViewModel?
    private var idCache: String?
    private var typeCache: String?
}
