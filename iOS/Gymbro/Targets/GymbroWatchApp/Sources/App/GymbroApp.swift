import SwiftUI

@main
struct GymbroWatchApp: App {

    @StateObject private var connectivityManager = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WorkoutListView(viewModel: WorkoutListViewModel(connectivityManager: connectivityManager))
            }
        }
    }
}
