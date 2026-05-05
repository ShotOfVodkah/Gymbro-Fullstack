import SwiftUI
import SwiftData

import GymbroWorkouts
import GymbroNavigation
import GymbroNetwork
import GymbroCommonUI
import GymbroAuth
import GymbroAnalytics

@main
struct GymbroApp: App {

    @State private var modelContainer: ModelContainer
    @State var tab: AppTab = .workouts
    @StateObject private var router: AppRouter
    @StateObject private var session = SessionManager.shared
    @StateObject private var profileOnboardingGate = ProfileOnboardingGate()
    private let appServicesFactory: AppServicesFactory
    
    init() {
        let isUITesting = AppEnvironment.isUITesting
        
        if AppEnvironment.shouldResetState {
            AppMicroservices.tokens.clear()
        }

        if AppEnvironment.shouldAuthorizeUser {
            SessionManager.shared.setUITestingAuthenticatedSession()
        }

        UIView.setAnimationsEnabled(!isUITesting)
        
        let r = AppRouter()
        let container: ModelContainer = {
            do {
                return try ModelContainer(
                    for: DivJsonCache.self, WorkoutsCache.self, ExercisesCache.self, OfflineActionEntity.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: isUITesting))
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }()
        _modelContainer = State(initialValue: container)
        _router = StateObject(wrappedValue: r)
        let clients: AppClients = AppEnvironment.shouldUseMockNetwork ? .mock : .real
        SessionManager.setAuthServiceOverride(AppEnvironment.shouldUseMockNetwork ? clients.auth : nil)
        self.appServicesFactory = AppServicesFactory(router: r, container: container, clients: clients, isUITesting: isUITesting)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if session.isAuthenticated {
                    if let userId = session.currentUserId, !userId.isEmpty,
                       !profileOnboardingGate.isCompleted(for: userId) {
                        NavigationStack {
                            appServicesFactory.makeProfileOnboarding {
                                profileOnboardingGate.markCompleted(for: userId)
                            }
                        }
                    } else {
                        NavigationStack(path: $router.path) {
                            ZStack(alignment: .bottom) {
                                Group {
                                    switch tab {
                                    case .workouts:
                                        appServicesFactory.makeWorkoutsScreen()
                                            .accessibilityIdentifier("screen.workouts")
                                            .navigationDestination(for: NavigationRoute.self) { route in
                                                appServicesFactory.makeDestinationView(for: route)
                                            }
                                    case .feeds:
                                        appServicesFactory.makeFeedsMainTab()
                                            .accessibilityIdentifier("screen.feeds")
                                            .navigationDestination(for: NavigationRoute.self) { route in
                                                appServicesFactory.makeDestinationView(for: route)
                                            }
                                    case .profile:
                                        appServicesFactory.makeProfileMainTab()
                                            .accessibilityIdentifier("screen.profile")
                                            .navigationDestination(for: NavigationRoute.self) { route in
                                                appServicesFactory.makeDestinationView(for: route)
                                            }
                                    case .challenge:
                                        appServicesFactory.makeChallengesMainTab()
                                            .accessibilityIdentifier("screen.challenges")
                                            .navigationDestination(for: NavigationRoute.self) { route in
                                                appServicesFactory.makeDestinationView(for: route)
                                            }
                                    case .perks:
                                        appServicesFactory.makePerksMainTab()
                                            .accessibilityIdentifier("screen.perks")
                                            .navigationDestination(for: NavigationRoute.self) { route in
                                                appServicesFactory.makeDestinationView(for: route)
                                            }
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .accessibilityIdentifier("app.main.content")
                                
                                AppTabBar(selected: $tab)
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 10)
                            }
                            .ignoresSafeArea(.container, edges: .bottom)
                        }
                    }
                } else {
                    AuthView(analytics: appServicesFactory.analytics, auth: appServicesFactory.auth)
                        .accessibilityIdentifier("auth.screen")
                }
            }
            .accessibilityIdentifier("app.root")
            .onAppear {
                if session.isAuthenticated {
                    appServicesFactory.startOfflineSyncIfNeeded()
                }
            }
            .onChange(of: session.isAuthenticated) { _, authenticated in
                if authenticated {
                    appServicesFactory.startOfflineSyncIfNeeded()
                } else {
                    appServicesFactory.clearAllLocalStoresOnLogout()
                    router.popToRoot()
                }
            }
        }
        .modelContainer(modelContainer)
    }
}
