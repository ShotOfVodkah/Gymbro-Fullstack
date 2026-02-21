import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation

public final class WorkoutBuilderFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        divLocalRepository: DivCacheRepository,
        actionsRepository: OfflineActionsRepository,
        modelModifier: WorkoutsModelModifier,
        localMapper: WorkoutsLocalMapper
    ) -> some View  {
        guard let viewModelCache else {
            let workoutsNetworkClient = WorkoutsNetworkClientImpl()
            let viewModel = WorkoutBuilderViewModel(
                networkClient: workoutsNetworkClient,
                router: router,
                divLocalRepository: divLocalRepository,
                actionsRepository: actionsRepository,
                modelModifier: modelModifier,
                localMapper: localMapper
            )
            viewModelCache = viewModel
            return WorkoutBuilderView(viewModel: viewModel)
        }
        return WorkoutBuilderView(viewModel: viewModelCache)
    }
    
    private var viewModelCache: WorkoutBuilderViewModel?
}
