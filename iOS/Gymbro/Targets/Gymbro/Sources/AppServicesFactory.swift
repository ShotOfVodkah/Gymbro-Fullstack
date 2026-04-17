import Foundation
import SwiftUI
import SwiftData

import GymbroWorkouts
import GymbroNetwork
import GymbroNavigation
import GymbroFeeds
import GymbroProfile
import GymbroTypes
import GymbroAnalytics

final class AppServicesFactory {
    let router: AppRouter
    
    let divLocalRepository: DivCacheRepository
    let workoutsRepository: WorkoutsCacheRepository
    let exercisesRepository: ExercisesRepository
    let actionsRepository: OfflineActionsRepository
    
    let workoutsModelModifier = WorkoutsModelModifier()
    let localMapper: WorkoutsLocalMapper

    let analytics: AnalyticsServiceImpl

    private let offlineSyncService: OfflineSyncService
    private var screenFactories = ScreenFactories()
    private var didStartOfflineSync = false
    
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
        let analyticsClient = AnalyticsClient(networkClient: AppMicroservices.shared.networkClient)
        self.analytics = AnalyticsServiceImpl(client: analyticsClient)
        watchConnectivityService.activate()
    }

    func startOfflineSyncIfNeeded() {
        guard !didStartOfflineSync else { return }
        didStartOfflineSync = true
        offlineSyncService.start()
    }

    func clearAllLocalStoresOnLogout() {
        divLocalRepository.clearAll()
        workoutsRepository.clearAll()
        exercisesRepository.clearAll()
        actionsRepository.clearAllActions()
        screenFactories.workoutsListFactory.resetViewModelCache()
    }

    @MainActor
    @ViewBuilder
    func makeDestinationView(for route: NavigationRoute) -> some View {
        switch route {
        case .workoutInfo(let id, let type):
            makeWorkoutInfoScreen(id: id, type: type)
        case .workoutPlayer(let id):
            makeWorkoutPlayerScreen(id: id)
        case .workoutBuilder:
            makeWorkoutBuilderScreen()
        case .workoutBuilderForType(let type, let id):
            makeWorkoutBuilderForTypeScreen(type: type, workoutId: id)
        case .workoutGenerator:
            makeWorkoutGeneratorScreen()
        
            // feeds
        case .feedsPeople:
            makeFeedsPeopleScreen()
        case .feedsCalendar(let context):
            makeFeedsCalendarScreen(context: context)
        case .feedsChat(let input):
            makeFeedsChatScreen(input: input)
            
            // profile
        case .profileMain(let mode):
            makeProfileMainScreen(mode: mode)
        case .profileEdit:
            makeEditProfileScreen()
        case .profileSettings:
            makeSettingsScreen()
            
            // change
        case .profileStatistics(let mode):
            FeedsMockDestinationView(
                title: mode == .myProfile ? "My Statistics" : "User Statistics",
                subtitle: "Mock statistics screen"
            )
        case .profilePosts(let userID, let userName):
            FeedsMockDestinationView(
                title: "\(userName)'s Posts",
                subtitle: "Mock posts screen for userID: \(userID)"
            )
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
            localMapper: localMapper,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeWorkoutInfoScreen(id: String, type: WorkoutInfoType) -> some View {
        screenFactories.workoutInfoFactory.makeView(
            id: id,
            type: type,
            router: router,
            divLocalRepository: divLocalRepository,
            actionsRepository: actionsRepository,
            modelModifier: workoutsModelModifier,
            сlient: AppMicroservices.workouts,
            localMapper: localMapper,
            analytics: analytics
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
            client: AppMicroservices.workouts,
            analytics: analytics
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
            localMapper: localMapper,
            analytics: analytics
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
            workoutId: workoutId,
            analytics: analytics
        )
    }
    
    // Feeds
    
    @MainActor
    func makeWorkoutGeneratorScreen() -> some View {
        screenFactories.workoutGeneratorFactory.makeView(
            router: router,
            modelModifier: workoutsModelModifier,
            actionsRepository: actionsRepository,
            workoutsRepository: workoutsRepository,
            client: AppMicroservices.workouts,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeFeedsMainTab() -> some View {
        screenFactories.feedsMainTabFactory.makeView(
            router: router,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeFeedsPeopleScreen() -> some View {
        screenFactories.feedsPeopleFactory.makeView(
            router: router,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeFeedsCalendarScreen(context: CalendarContext) -> some View {
        screenFactories.feedsCalendarFactory.makeView(
            input: CalendarScreenInput(context: context),
            router: router,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeFeedsChatScreen(input: ChatSessionInput) -> some View {
        screenFactories.feedsChatFactory.makeView(
            input: input,
            router: router,
            analytics: analytics
        )
    }
    
    // Profile
    
    @MainActor
    func makeProfileMainTab() -> some View {
        makeProfileMainScreen(mode: .myProfile)
    }
    
    @MainActor
    func makeProfileMainScreen(mode: ProfileViewMode) -> some View {
        screenFactories.profileMainTabFactory.makeView(
            router: router,
            mode: mode,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeEditProfileScreen() -> some View {
        screenFactories.editProfileFactory.makeView(
            router: router,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeSettingsScreen() -> some View {
        screenFactories.settingsFactory.makeView(
            router: router,
            analytics: analytics
        )
    }
}

private struct ScreenFactories {
    
    // Workout factories
    
    lazy var workoutsListFactory = WorkoutsListFactoryImpl()
    lazy var workoutInfoFactory = WorkoutInfoFactoryImpl()
    lazy var workoutPlayerFactory = WorkoutPlayerFactoryImpl()
    lazy var workoutBuilderFactory = WorkoutBuilderFactoryImpl()
    lazy var workoutBuilderForTypeFactory = WorkoutBuilderForTypeFactoryImpl()
    lazy var workoutGeneratorFactory = WorkoutGeneratorFactoryImpl()
    
    // Feeds factories
    
    lazy var feedsMainTabFactory = FeedsMainTabFactoryImpl()
    lazy var feedsPeopleFactory = FeedsPeopleFactoryImpl()
    lazy var feedsCalendarFactory = FeedsCalendarFactoryImpl()
    lazy var feedsChatFactory = FeedsChatFactoryImpl()
    
    // Profile factories
    
    lazy var profileMainTabFactory = ProfileMainTabFactoryImpl()
    lazy var editProfileFactory = EditProfileFactoryImpl()
    lazy var settingsFactory = ProfileSettingsFactoryImpl()
}
