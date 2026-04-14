import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation
import GymbroTypes

public final class WorkoutInfoFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        id: String,
        type: WorkoutInfoType,
        router: any Router,
        divLocalRepository: DivCacheRepository,
        actionsRepository: OfflineActionsRepository,
        modelModifier: WorkoutsModelModifier,
        сlient: WorkoutsClient,
        localMapper: WorkoutsLocalMapper,
        analytics: any AnalyticsService
    ) -> some View {
        guard let viewModelCache, id == idCache else {
            let service = WorkoutInfoServiceImpl(
                networkClient: сlient,
                divLocalRepository: divLocalRepository,
                actionsRepository: actionsRepository,
                localMapper: localMapper
            )
            let viewModel = WorkoutInfoViewModel(
                id: id,
                type: type,
                service: service,
                router: router,
                modelModifier: modelModifier,
                analytics: analytics
            )
            viewModelCache = viewModel
            idCache = id
            return WorkoutInfoView(viewModel: viewModel, id: id, type: type)
        }
        return WorkoutInfoView(viewModel: viewModelCache, id: id, type: type)
    }

    private var idCache: String?
    private var viewModelCache: WorkoutInfoViewModel?
}
