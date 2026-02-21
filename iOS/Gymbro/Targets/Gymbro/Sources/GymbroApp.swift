import SwiftUI
import SwiftData

import GymbroWorkouts
import GymbroNavigation
import GymbroNetwork
import GymbroCommonUI

@main
struct GymbroApp: App {

    @State private var modelContainer: ModelContainer
    @State var tab: AppTab = .workouts
    @StateObject private var router = AppRouter()
    private let appServicesFactory: AppServicesFactory
    
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
                        case .profile:
                            Text("Profile")
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
        }
        .modelContainer(modelContainer)
    }

}
