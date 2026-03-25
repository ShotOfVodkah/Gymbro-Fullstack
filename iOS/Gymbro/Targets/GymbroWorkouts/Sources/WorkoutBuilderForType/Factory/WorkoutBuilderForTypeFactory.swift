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
        localMapper: WorkoutsLocalMapper,
        modelModifier: WorkoutsModelModifier,
        type: String?,
        workoutId: String?
    ) -> some View {
        guard let viewModelCache, typeCache == type, idCache == workoutId else {
            let service = WorkoutBuilderForTypeServiceImpl(
                networkClient: WorkoutsNetworkClientImpl(),
                divLocalRepository: divLocalRepository,
                workoutsRepository: workoutsRepository,
                exercisesRepository: exercisesRepository,
                actionsRepository: actionsRepository,
                localMapper: localMapper
            )
            let viewModel = WorkoutBuilderForTypeViewModel(
                service: service,
                router: router,
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
