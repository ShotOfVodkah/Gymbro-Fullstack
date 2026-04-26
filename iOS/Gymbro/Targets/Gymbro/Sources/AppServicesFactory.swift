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
    private let streakWidget: StreakWidgetControlling
    private let activityCalendarWidget: ActivityCalendarWidgetControlling

    private let offlineSyncService: OfflineSyncService
    private var screenFactories = ScreenFactories()
    private var didStartOfflineSync = false
    
    private let watchConnectivityService: WatchConnectivityService

    init(
        router: AppRouter,
        container: ModelContainer
    ) {
        self.router = router

        let store = StreakWidgetStore()
        let reloader = StreakWidgetCenterTimelineReloader()
        let streakService = StreakWidgetControllingService(store: store, reloader: reloader)
        self.streakWidget = streakService

        let activityCalendarStore = ActivityCalendarWidgetStore()
        let activityCalendarReloader = ActivityCalendarWidgetCenterTimelineReloader()
        let activityCalendarService = ActivityCalendarWidgetControllingService(
            store: activityCalendarStore,
            reloader: activityCalendarReloader
        )
        self.activityCalendarWidget = activityCalendarService
        
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
            feedsClient: AppMicroservices.feeds,
            modelModifier: workoutsModelModifier,
            streakWidget: streakService,
            activityCalendarWidget: activityCalendarService
        )
        self.watchConnectivityService = WatchConnectivityService(
            workoutsRepository: workoutsRepository,
            feedsClient: AppMicroservices.feeds,
            streakWidget: streakService,
            activityCalendarWidget: activityCalendarService
        )
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
        case .workoutShare(input: let input):
            makeWorkoutsShareScreen(input: input)
        case .feedsPeople(let input):
            makeFeedsPeopleScreen(input: input)
        case .feedsCalendar(let context):
            makeFeedsCalendarScreen(context: context)
        case .feedsChat(let input):
            makeFeedsChatScreen(input: input)
        case .feedsPosts(let input):
            makePostsScreen(input: input)
            
            // profile
        case .profileMain(let mode):
            makeProfileMainScreen(mode: mode)
        case .profileEdit:
            makeEditProfileScreen()
        case .profileSettings:
            makeSettingsScreen()
        case .profileStatistics(let mode):
            makeStatisticsScreen(mode: mode)
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
            feedsClient: AppMicroservices.feeds,
            localMapper: localMapper,
            analytics: analytics,
            streakWidget: streakWidget,
            activityCalendarWidget: activityCalendarWidget
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
            feedsClient: AppMicroservices.feeds,
            analytics: analytics,
            streakWidget: streakWidget,
            activityCalendarWidget: activityCalendarWidget
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
    
    // Feeds
    
    @MainActor
    func makeWorkoutsShareScreen(input: WorkoutShareInput) -> some View {
        screenFactories.workoutsShareFactory.makeView(
            input: input,
            router: router,
            client: AppMicroservices.feeds,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeFeedsMainTab() -> some View {
        screenFactories.feedsMainTabFactory.makeView(
            router: router,
            client: AppMicroservices.feeds,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeFeedsPeopleScreen(input: PeopleScreenInput) -> some View {
        screenFactories.feedsPeopleFactory.makeView(
            input: input,
            router: router,
            client: AppMicroservices.feeds,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeFeedsCalendarScreen(context: CalendarContext) -> some View {
        screenFactories.feedsCalendarFactory.makeView(
            input: CalendarScreenInput(context: context),
            router: router,
            client: AppMicroservices.feeds,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeFeedsChatScreen(input: ChatSessionInput) -> some View {
        screenFactories.feedsChatFactory.makeView(
            input: input,
            router: router,
            client: AppMicroservices.feeds,
            analytics: analytics
        )
    }
    
    @MainActor
    func makePostsScreen(input: PostsScreenInput) -> some View {
        screenFactories.feedsPostsFactory.makeView(
            input: input,
            router: router,
            client: AppMicroservices.feeds,
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
            gateway: ProfileGatewayImpl(profileClient: AppMicroservices.profile, feedsClient: AppMicroservices.feeds),
            analytics: analytics
        )
    }
    
    @MainActor
    func makeEditProfileScreen() -> some View {
        screenFactories.editProfileFactory.makeView(
            router: router,
            client: AppMicroservices.profile,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeSettingsScreen() -> some View {
        screenFactories.settingsFactory.makeView(
            router: router,
            client: AppMicroservices.profile,
            analytics: analytics
        )
    }
    
    @MainActor
    func makeStatisticsScreen(mode: ProfileViewMode) -> some View {
        screenFactories.statisticsFactory.makeView(
            mode: mode,
            router: router,
            client: AppMicroservices.profile,
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
    
    lazy var workoutsShareFactory = WorkoutShareFactoryImpl()
    lazy var feedsMainTabFactory = FeedsMainTabFactoryImpl()
    lazy var feedsPeopleFactory = FeedsPeopleFactoryImpl()
    lazy var feedsCalendarFactory = FeedsCalendarFactoryImpl()
    lazy var feedsChatFactory = FeedsChatFactoryImpl()
    lazy var feedsPostsFactory = FeedsProfilePostsFactoryImpl()
    
    // Profile factories
    
    lazy var profileMainTabFactory = ProfileMainTabFactoryImpl()
    lazy var editProfileFactory = EditProfileFactoryImpl()
    lazy var settingsFactory = ProfileSettingsFactoryImpl()
    lazy var statisticsFactory = ProfileStatisticsFactoryImpl()
}
