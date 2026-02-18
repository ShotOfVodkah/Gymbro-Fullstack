import Foundation
import SwiftUI
import SwiftData

import GymbroWorkouts
import GymbroNetwork
import GymbroNavigation

final class AppServicesFactory {
    let router: AppRouter
    
    let divLocalRepository: DivCacheRepository
    let workoutsRepository: WorkoutsCacheRepository
    let exercisesRepository: ExercisesRepository
    let actionsRepository: OfflineActionsRepository
    
    let workoutsModelModifier = WorkoutsModelModifier()
    let localMapper: WorkoutsLocalMapper
    
    private var screenFactories = ScreenFactories()

    init(
        router: AppRouter,
        container: ModelContainer
    ) {
        self.router = router
        
        let cacheDS = WorkoutsDivCacheDataSource(container: container)
        self.divLocalRepository = DivCacheRepository(dataSource: cacheDS)
        
        let workoutsCacheDS = WorkoutsSwiftDataCacheDataSource(container: container)
        self.workoutsRepository = WorkoutsCacheRepository(dataSource: workoutsCacheDS)
        
        let exercisesDS = ExercisesSwiftDataSource(container: container)
        self.exercisesRepository = ExercisesRepository(dataSource: exercisesDS)
        
        let offlineDS = OfflineActionsSwiftDataSource(container: container)
        self.actionsRepository = OfflineActionsRepository(dataSource: offlineDS)
        
        self.localMapper = WorkoutsLocalMapper(
            divLocalRepository: divLocalRepository,
            workoutsLocalRepository: workoutsRepository
        )
    }

    @MainActor
    @ViewBuilder
    func makeDestinationView(for route: NavigationRoute) -> some View {
        switch route {
        case .workoutInfo(let id):
            makeWorkoutInfoScreen(id: id)
        case .workoutBuilder:
            makeWorkoutBuilderScreen()
        case .workoutBuilderForType(let type, let id):
            makeWorkoutBuilderForTypeScreen(type: type, workoutId: id)
        }
    }
    
    // Workouts

    @MainActor
    func makeWorkoutsScreen() -> some View {
        screenFactories.workoutsListFactory.makeView(
            router: router,
            divLocalRepository: divLocalRepository,
            workoutsRepository: workoutsRepository,
            exercisesRepository: exercisesRepository,
            modelModifier: workoutsModelModifier,
            localMapper: localMapper
        )
    }
    
    @MainActor
    func makeWorkoutInfoScreen(id: String) -> some View {
        screenFactories.workoutInfoFactory.makeView(
            id: id,
            router: router,
            divLocalRepository: divLocalRepository,
            actionsRepository: actionsRepository,
            modelModifier: workoutsModelModifier,
            localMapper: localMapper
        )
    }
    
    @MainActor
    func makeWorkoutBuilderScreen() -> some View {
        screenFactories.workoutBuilderFactory.makeView(
            router: router,
            divLocalRepository: divLocalRepository,
            actionsRepository: actionsRepository,
            modelModifier: workoutsModelModifier,
            localMapper: localMapper
        )
    }
    
    @MainActor
    func makeWorkoutBuilderForTypeScreen(type: String?, workoutId: String?) -> some View {
        screenFactories.workoutBuilderForTypeFactory.makeView(
            router: router,
            divLocalRepository: divLocalRepository,
            workoutsRepository: workoutsRepository,
            exercisesRepository: exercisesRepository,
            actionsRepository: actionsRepository,
            modelModifier: workoutsModelModifier,
            type: type,
            workoutId: workoutId
        )
    }
    
}

private struct ScreenFactories {
    
    // Workout factories
    
    lazy var workoutsListFactory = WorkoutsListFactoryImpl()
    lazy var workoutInfoFactory = WorkoutInfoFactoryImpl()
    lazy var workoutBuilderFactory = WorkoutBuilderFactoryImpl()
    lazy var workoutBuilderForTypeFactory = WorkoutBuilderForTypeFactoryImpl()
}
