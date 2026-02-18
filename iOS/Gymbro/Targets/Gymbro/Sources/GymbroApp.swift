import SwiftUI
import GymbroWorkouts
import GymbroNavigation
import GymbroNetwork
import SwiftData

@main
struct GymbroApp: App {

    @State private var modelContainer: ModelContainer
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
//                AuthScreen()
                appServicesFactory.makeWorkoutsScreen()
                    .navigationDestination(for: NavigationRoute.self) { route in
                        appServicesFactory.makeDestinationView(for: route)
                    }
            }
        }
        .modelContainer(modelContainer)
    }

}
