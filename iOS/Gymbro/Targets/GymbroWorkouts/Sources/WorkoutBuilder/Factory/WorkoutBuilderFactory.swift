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
        сlient: WorkoutsClient,
        localMapper: WorkoutsLocalMapper
    ) -> some View {
        guard let viewModelCache else {
            let service = WorkoutBuilderServiceImpl(
                networkClient: сlient,
                divLocalRepository: divLocalRepository,
                actionsRepository: actionsRepository,
                localMapper: localMapper
            )
            let viewModel = WorkoutBuilderViewModel(
                service: service,
                router: router,
                modelModifier: modelModifier
            )
            viewModelCache = viewModel
            return WorkoutBuilderView(viewModel: viewModel)
        }
        return WorkoutBuilderView(viewModel: viewModelCache)
    }

    private var viewModelCache: WorkoutBuilderViewModel?
}
