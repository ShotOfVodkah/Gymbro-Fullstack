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
    
    private var screenFactories = ScreenFactories()

    init(
        router: AppRouter,
        container: ModelContainer
    ) {
        self.router = router
        let cacheDS = WorkoutsDivCacheDataSource(container: container)
        self.workoutsLocalRepository = DivCacheRepository(dataSource: cacheDS)
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
            modelModifier: workoutsModelModifier
        )
    }
    
    @MainActor
    func makeWorkoutInfoScreen(id: String) -> some View {
        screenFactories.workoutInfoFactory.makeView(
            id: id,
            router: router,
            localRepository: workoutsLocalRepository,
            modelModifier: workoutsModelModifier
        )
    }
    
    @MainActor
    func makeWorkoutBuilderScreen() -> some View {
        screenFactories.workoutBuilderFactory.makeView()
    }
    
}

private struct ScreenFactories {
    
    // Workout factories
    
    lazy var workoutsListFactory = WorkoutsListFactoryImpl()
    lazy var workoutInfoFactory = WorkoutInfoFactoryImpl()
    lazy var workoutBuilderFactory = WorkoutBuilderFactoryImpl()
}
