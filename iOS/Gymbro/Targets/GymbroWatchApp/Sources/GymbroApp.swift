import SwiftUI
import SwiftData

@main
struct GymbroApp: App {
    
    init() {
        self.manager = WatchConnectivityManager()
    }
    
    private var manager: WatchConnectivityManager
    
    var body: some Scene {
        WindowGroup {
            Text("Watch")
        }
    }
}
