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
        localRepository: DivCacheRepository,
        modelModifier: WorkoutsModelModifier
    ) -> some View  {
        guard let viewModelCache, id == idCache else {
            let workoutsNetworkClient = WorkoutsNetworkClientImpl()
            let localMapper = WorkoutInfoLocalMapper()
            let viewModel = WorkoutInfoViewModel(
                id: id,
                networkClient: workoutsNetworkClient,
                localRepository: localRepository,
                router: router,
                modelModifier: modelModifier,
                localMapper: localMapper
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

