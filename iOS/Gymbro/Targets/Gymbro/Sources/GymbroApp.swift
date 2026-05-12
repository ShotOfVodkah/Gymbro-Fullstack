import SwiftUI
import SwiftData

import GymbroWorkouts
import GymbroNavigation
import GymbroNetwork
import GymbroCommonUI
import GymbroAuth
import GymbroAnalytics
import GymbroTypes

@main
struct GymbroApp: App {

    @State private var modelContainer: ModelContainer
    @State var tab: AppTab = .workouts
    @State private var didApplyUITestRoutes = false
    @StateObject private var router: AppRouter
    @StateObject private var session = SessionManager.shared
    @StateObject private var profileOnboardingGate = ProfileOnboardingGate()
    private let appServicesFactory: AppServicesFactory
    
    init() {
        let isUITesting = AppEnvironment.isUITesting
        
        if AppEnvironment.shouldResetState {
            AppMicroservices.tokens.clear()
            if AppEnvironment.isUITesting {
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "termsAccepted_v1")
                defaults.removeObject(forKey: "privacyAccepted_v1")
                defaults.removeObject(
                    forKey: ProfileOnboardingGate.userDefaultsKey(
                        for: SessionManager.uiTestingUserId
                    )
                )
            }
        }

        if AppEnvironment.shouldAuthorizeUser {
            SessionManager.shared.setUITestingAuthenticatedSession()
            if AppEnvironment.isUITesting {
                UserDefaults.standard.set(
                    true,
                    forKey: ProfileOnboardingGate.userDefaultsKey(
                        for: SessionManager.uiTestingUserId
                    )
                )
            }
        }

        UIView.setAnimationsEnabled(!isUITesting)
        
        let r = AppRouter()
        let container: ModelContainer = {
            do {
                return try ModelContainer(
                    for: DivJsonCache.self,
                    WorkoutsCache.self,
                    ExercisesCache.self,
                    OfflineActionEntity.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: isUITesting)
                )
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }()

        _modelContainer = State(initialValue: container)
        _router = StateObject(wrappedValue: r)

        let clients: AppClients = AppEnvironment.shouldUseMockNetwork ? .mock : .real
        SessionManager.setAuthServiceOverride(AppEnvironment.shouldUseMockNetwork ? clients.auth : nil)

        self.appServicesFactory = AppServicesFactory(
            router: r,
            container: container,
            clients: clients,
            isUITesting: isUITesting
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if session.isAuthenticated {
                        if let userId = session.currentUserId,
                           !userId.isEmpty,
                           !profileOnboardingGate.isCompleted(for: userId) {

                            NavigationStack {
                                ZStack {
                                    appServicesFactory.makeProfileOnboarding {
                                        profileOnboardingGate.markCompleted(for: userId)
                                    }

                                    UITestMarker(id: "profile.onboarding.screen")
                                }
                            }

                        } else {
                            mainAppView
                        }
                    } else {
                        ZStack {
                            AuthView(
                                analytics: appServicesFactory.analytics,
                                auth: appServicesFactory.auth
                            )

                            UITestMarker(id: "auth.screen")
                        }
                    }
                }

                UITestMarker(id: "app.root")
            }
            .onAppear {
                if session.isAuthenticated {
                    appServicesFactory.startOfflineSyncIfNeeded()
                    applyUITestRoutesIfNeeded()
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

    private var mainAppView: some View {
        NavigationStack(path: $router.path) {
            ZStack(alignment: .bottom) {
                if AppEnvironment.isUITesting {
                    UITestMarker(
                        id: AppEnvironment.shouldUseMockNetwork
                        ? "debug.network.mock"
                        : "debug.network.real"
                    )
                }

                Group {
                    switch tab {
                    case .workouts:
                        ZStack {
                            appServicesFactory.makeWorkoutsScreen()
                                .navigationDestination(for: NavigationRoute.self) { route in
                                    appServicesFactory.makeDestinationView(for: route)
                                }

                            UITestMarker(id: "workouts.list.screen")
                        }

                    case .feeds:
                        ZStack {
                            appServicesFactory.makeFeedsMainTab()
                                .navigationDestination(for: NavigationRoute.self) { route in
                                    appServicesFactory.makeDestinationView(for: route)
                                }

                            UITestMarker(id: "feeds.main.screen")
                        }

                    case .profile:
                        ZStack {
                            appServicesFactory.makeProfileMainTab()
                                .navigationDestination(for: NavigationRoute.self) { route in
                                    appServicesFactory.makeDestinationView(for: route)
                                }

                            UITestMarker(id: "profile.main.screen")
                        }

                    case .challenge:
                        ZStack {
                            appServicesFactory.makeChallengesMainTab()
                                .navigationDestination(for: NavigationRoute.self) { route in
                                    appServicesFactory.makeDestinationView(for: route)
                                }

                            UITestMarker(id: "challenges.main.screen")
                        }

                    case .perks:
                        ZStack {
                            appServicesFactory.makePerksMainTab()
                                .navigationDestination(for: NavigationRoute.self) { route in
                                    appServicesFactory.makeDestinationView(for: route)
                                }

                            UITestMarker(id: "perks.main.screen")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                UITestMarker(id: "app.main.content")

                AppTabBar(selected: $tab)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
            .background(Color.black.ignoresSafeArea(.all))
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private func applyUITestRoutesIfNeeded() {
        guard AppEnvironment.isUITesting else { return }
        guard AppEnvironment.shouldPresentWorkoutShareFromUITest else { return }
        guard !didApplyUITestRoutes else { return }
        didApplyUITestRoutes = true

        let shareInput = WorkoutShareInput(
            sessionID: "uitest_share_session",
            workoutID: "uitest_workout_w",
            workoutName: "UI Strength",
            workoutType: "strength",
            completedAt: Date(timeIntervalSince1970: 1_717_000_000)
        )

        DispatchQueue.main.async {
            router.navigate(to: .workoutShare(input: shareInput))
        }
    }
}
