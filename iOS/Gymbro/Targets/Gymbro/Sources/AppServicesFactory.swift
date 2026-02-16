import Foundation
import SwiftUI
import SwiftData

import GymbroWorkouts
import GymbroNetwork
import GymbroNavigation

final class AppServicesFactory {
    let router: AppRouter
    
    let workoutsLocalRepository: DivCacheRepository
    let workoutsModelModifier = WorkoutsModelModifier()
    let localMapper: WorkoutsLocalMapper
    
    private var screenFactories = ScreenFactories()

    init(
        router: AppRouter,
        container: ModelContainer
    ) {
        self.router = router
        let cacheDS = WorkoutsDivCacheDataSource(container: container)
        self.workoutsLocalRepository = DivCacheRepository(dataSource: cacheDS)
        self.localMapper = WorkoutsLocalMapper(localRepository: workoutsLocalRepository)
    }

    @MainActor
    @ViewBuilder
    func makeDestinationView(for route: NavigationRoute) -> some View {
        switch route {
        case .workoutInfo(let id):
            makeWorkoutInfoScreen(id: id)
        case .workoutBuilder:
            makeWorkoutBuilderScreen()
            
        }
    }
    
    // Workouts

    @MainActor
    func makeWorkoutsScreen() -> some View {
        screenFactories.workoutsListFactory.makeView(
            router: router,
            localRepository: workoutsLocalRepository,
            modelModifier: workoutsModelModifier,
            localMapper: localMapper
        )
    }
    
    @MainActor
    func makeWorkoutInfoScreen(id: String) -> some View {
        screenFactories.workoutInfoFactory.makeView(
            id: id,
            router: router,
            localRepository: workoutsLocalRepository,
            modelModifier: workoutsModelModifier,
            localMapper: localMapper
        )
    }
    
    @MainActor
    func makeWorkoutBuilderScreen() -> some View {
        screenFactories.workoutBuilderFactory.makeView(
            router: router,
            localRepository: workoutsLocalRepository,
            modelModifier: workoutsModelModifier,
            localMapper: localMapper
        )
    }
    
}

private struct ScreenFactories {
    
    // Workout factories
    
    lazy var workoutsListFactory = WorkoutsListFactoryImpl()
    lazy var workoutInfoFactory = WorkoutInfoFactoryImpl()
    lazy var workoutBuilderFactory = WorkoutBuilderFactoryImpl()
}
