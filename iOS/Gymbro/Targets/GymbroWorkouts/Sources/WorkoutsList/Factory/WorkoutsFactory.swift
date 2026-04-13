import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation
import GymbroTypes

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
        localMapper: WorkoutsLocalMapper,
        analytics: any AnalyticsService
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
                modelModifier: modelModifier,
                analytics: analytics
            )
            viewModelCache = viewModel
            return WorkoutsListView(viewModel: viewModel)
        }
        return WorkoutsListView(viewModel: viewModelCache)
    }

    public func resetViewModelCache() {
        viewModelCache = nil
    }

    private var viewModelCache: WorkoutsListViewModel?
}
