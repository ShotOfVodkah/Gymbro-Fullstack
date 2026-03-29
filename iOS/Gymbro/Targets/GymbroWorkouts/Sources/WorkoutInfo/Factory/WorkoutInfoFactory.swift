import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation

public final class WorkoutInfoFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        id: String,
        router: any Router,
        divLocalRepository: DivCacheRepository,
        actionsRepository: OfflineActionsRepository,
        modelModifier: WorkoutsModelModifier,
        сlient: WorkoutsClient,
        localMapper: WorkoutsLocalMapper
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
                service: service,
                router: router,
                modelModifier: modelModifier
            )
            viewModelCache = viewModel
            idCache = id
            return WorkoutInfoView(viewModel: viewModel, id: id)
        }
        return WorkoutInfoView(viewModel: viewModelCache, id: id)
    }

    private var idCache: String?
    private var viewModelCache: WorkoutInfoViewModel?
}
