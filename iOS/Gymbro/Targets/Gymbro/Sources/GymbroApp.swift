import SwiftUI
import GymbroWorkouts

@main
struct GymbroApp: App {
    var body: some Scene {
        WindowGroup {
            appServicesFactory.makeWorkoutsScreen()
        }
    }
    
    let appServicesFactory = AppServicesFactory()
}
