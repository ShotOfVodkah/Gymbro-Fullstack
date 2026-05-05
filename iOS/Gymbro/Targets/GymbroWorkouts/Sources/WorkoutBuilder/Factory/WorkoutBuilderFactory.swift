import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation
import GymbroTypes

public final class WorkoutBuilderFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        divLocalRepository: DivCacheRepository,
        actionsRepository: OfflineActionsRepository,
        modelModifier: WorkoutsModelModifier,
        сlient: any WorkoutsClientProtocol,
        localMapper: WorkoutsLocalMapper,
        analytics: any AnalyticsService
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
                modelModifier: modelModifier,
                analytics: analytics
            )
            viewModelCache = viewModel
            return WorkoutBuilderView(viewModel: viewModel)
        }
        return WorkoutBuilderView(viewModel: viewModelCache)
    }

    private var viewModelCache: WorkoutBuilderViewModel?
}
