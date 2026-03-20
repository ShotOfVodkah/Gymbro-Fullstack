import SwiftUI
import SwiftData

import GymbroWorkouts
import GymbroNavigation
import GymbroNetwork
import GymbroCommonUI
import GymbroAuth

@main
struct GymbroApp: App {

    @State private var modelContainer: ModelContainer
    @State var tab: AppTab = .workouts
    @StateObject private var router = AppRouter()
    @StateObject private var session = SessionManager.shared
    private let appServicesFactory: AppServicesFactory
    
    private var authBinding: Binding<Bool> {
        Binding(
            get: { !session.isAuthenticated },
            set: { _ in }
        )
    }
    
    init() {
        let r = AppRouter()
        let container: ModelContainer = {
            do {
                return try ModelContainer(
                    for: DivJsonCache.self, WorkoutsCache.self, ExercisesCache.self, OfflineActionEntity.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: false))
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }()
        _modelContainer = State(initialValue: container)
        _router = StateObject(wrappedValue: r)
        self.appServicesFactory = AppServicesFactory(router: r, container: container)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                ZStack(alignment: .bottom) {
                    Group {
                        switch tab {
                        case .workouts:
                            appServicesFactory.makeWorkoutsScreen()
                                .navigationDestination(for: NavigationRoute.self) { route in
                                    appServicesFactory.makeDestinationView(for: route)
                                }
                        case .feeds:
                            appServicesFactory.makeFeedsMainTab()
                                .navigationDestination(for: NavigationRoute.self) { route in
                                    appServicesFactory.makeDestinationView(for: route)
                                }
                        case .profile:
                            appServicesFactory.makeProfileMainTab()
                                .navigationDestination(for: NavigationRoute.self) { route in
                                    appServicesFactory.makeDestinationView(for: route)
                                }
                        case .challenge:
                            Text("Challenges")
                        case .perks:
                            Text("Perks")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    AppTabBar(selected: $tab)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .fullScreenCover(isPresented: authBinding) {
                AuthView()
            }
        }
        .modelContainer(modelContainer)
    }
}
