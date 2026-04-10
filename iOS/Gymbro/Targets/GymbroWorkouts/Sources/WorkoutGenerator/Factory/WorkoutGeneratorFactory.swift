import Foundation
import SwiftUI

import GymbroNavigation
import GymbroNetwork

public final class WorkoutGeneratorFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        workoutsRepository: WorkoutsCacheRepository,
        client: WorkoutsClient
    ) -> some View {
        guard let viewModelCache else {
            let service = WorkoutGeneratorServiceImpl(
                client: client,
                workoutsRepository: workoutsRepository
            )
            let viewModel = WorkoutGeneratorViewModel(
                modelModifier: modelModifier,
                router: router,
                service: service
            )
            viewModelCache = viewModel
            return WorkoutGeneratorView(viewModel: viewModel)
        }
        return WorkoutGeneratorView(viewModel: viewModelCache)
    }

    private var idCache: String?
    private var viewModelCache: WorkoutGeneratorViewModel?
}
