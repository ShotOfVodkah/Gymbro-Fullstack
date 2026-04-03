import Foundation
import SwiftUI
import SwiftData

import GymbroWorkouts
import GymbroNetwork
import GymbroNavigation
import GymbroFeeds
import GymbroProfile

final class AppServicesFactory {
    let router: AppRouter
    
    let divLocalRepository: DivCacheRepository
    let workoutsRepository: WorkoutsCacheRepository
    let exercisesRepository: ExercisesRepository
    let actionsRepository: OfflineActionsRepository
    
    let workoutsModelModifier = WorkoutsModelModifier()
    let localMapper: WorkoutsLocalMapper

    private let offlineSyncService: OfflineSyncService
    private var screenFactories = ScreenFactories()
    
    private let watchConnectivityService: WatchConnectivityService

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

        self.offlineSyncService = OfflineSyncService(
            actionsRepository: actionsRepository,
            networkClient: AppMicroservices.workouts,
            modelModifier: workoutsModelModifier
        )
        self.watchConnectivityService = WatchConnectivityService(workoutsRepository: workoutsRepository)
        
        offlineSyncService.start()
        watchConnectivityService.activate()
    }

    @MainActor
    @ViewBuilder
    func makeDestinationView(for route: NavigationRoute) -> some View {
        switch route {
        case .workoutInfo(let id):
            makeWorkoutInfoScreen(id: id)
        case .workoutPlayer(let id):
            makeWorkoutPlayerScreen(id: id)
        case .workoutBuilder:
            makeWorkoutBuilderScreen()
        case .workoutBuilderForType(let type, let id):
            makeWorkoutBuilderForTypeScreen(type: type, workoutId: id)
        
            // feeds
        case .feedsPeople:
            FeedsMockDestinationView(title: "People", subtitle: "Mock people screen")
        case .feedsCalendar:
            FeedsMockDestinationView(title: "Calendar", subtitle: "Mock calendar screen")
        case .feedsCreateCommunity:
            FeedsMockDestinationView(title: "Create Community", subtitle: "Mock create community screen")
        case .feedsCreatePost:
            FeedsMockDestinationView(title: "Create Post", subtitle: "Mock create post screen")
        case .feedsCommunity(let title):
            FeedsMockDestinationView(title: title, subtitle: "Mock community screen")
        case .feedsPost(let title):
            FeedsMockDestinationView(title: title, subtitle: "Mock post details screen")
        case .feedsComments(let title):
            FeedsMockDestinationView(title: "Comments", subtitle: "Mock comments for \(title)")
        case .feedsExercise(let title):
            FeedsMockDestinationView(title: title, subtitle: "Mock exercise screen")
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
            client: AppMicroservices.workouts,
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
            сlient: AppMicroservices.workouts,
            localMapper: localMapper
        )
    }

    @MainActor
    func makeWorkoutPlayerScreen(id: String) -> some View {
        screenFactories.workoutPlayerFactory.makeView(
            id: id,
            router: router,
            modelModifier: workoutsModelModifier,
            workoutsRepository: workoutsRepository,
            actionsRepository: actionsRepository,
            client: AppMicroservices.workouts
        )
    }
    
    @MainActor
    func makeWorkoutBuilderScreen() -> some View {
        screenFactories.workoutBuilderFactory.makeView(
            router: router,
            divLocalRepository: divLocalRepository,
            actionsRepository: actionsRepository,
            modelModifier: workoutsModelModifier,
            сlient: AppMicroservices.workouts,
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
            localMapper: localMapper,
            modelModifier: workoutsModelModifier,
            сlient: AppMicroservices.workouts,
            type: type,
            workoutId: workoutId
        )
    }
    
    // Feeds
    
    @MainActor
    func makeFeedsMainTab() -> some View {
        screenFactories.feedsMainTabFactory.makeView(router: router)
    }
    
    @MainActor
    func makeProfileMainTab() -> some View {
        screenFactories.profileMainTabFactory.makeView()
    }
}

private struct ScreenFactories {
    
    // Workout factories
    
    lazy var workoutsListFactory = WorkoutsListFactoryImpl()
    lazy var workoutInfoFactory = WorkoutInfoFactoryImpl()
    lazy var workoutPlayerFactory = WorkoutPlayerFactoryImpl()
    lazy var workoutBuilderFactory = WorkoutBuilderFactoryImpl()
    lazy var workoutBuilderForTypeFactory = WorkoutBuilderForTypeFactoryImpl()
    
    // Feeds factories
    
    lazy var feedsMainTabFactory = FeedsMainTabFactoryImpl()
    
    // Profile factories
    
    lazy var profileMainTabFactory = ProfileMainTabFactoryImpl()
}
