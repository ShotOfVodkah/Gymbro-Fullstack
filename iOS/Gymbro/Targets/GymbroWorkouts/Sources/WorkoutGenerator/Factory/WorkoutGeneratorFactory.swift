import Foundation
import SwiftUI

import GymbroTypes
import GymbroNavigation
import GymbroNetwork

public final class WorkoutGeneratorFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        actionsRepository: OfflineActionsRepository,
        workoutsRepository: WorkoutsCacheRepository,
        client: WorkoutsClient,
        analytics: any AnalyticsService
    ) -> some View {
        guard let viewModelCache else {
            let service = WorkoutGeneratorServiceImpl(
                client: client,
                workoutsRepository: workoutsRepository,
                actionsRepository: actionsRepository
            )
            let viewModel = WorkoutGeneratorViewModel(
                modelModifier: modelModifier,
                router: router,
                service: service,
                analytics: analytics
            )
            viewModelCache = viewModel
            return WorkoutGeneratorView(viewModel: viewModel)
        }
        return WorkoutGeneratorView(viewModel: viewModelCache)
    }

    private var idCache: String?
    private var viewModelCache: WorkoutGeneratorViewModel?
}
