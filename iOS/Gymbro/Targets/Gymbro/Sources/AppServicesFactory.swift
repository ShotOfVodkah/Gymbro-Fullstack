import Foundation
import SwiftUI

import GymbroWorkouts
import GymbroNetwork

final class AppServicesFactory {
    
    func makeWorkoutsScreen() -> some View {
        return screenFactories.workoutsFactory.makeWorkoutsScreen()
    }
    
    private let screenFactories = ScreenFactories()
}

private struct ScreenFactories {
    let workoutsFactory = WorkoutsFactory(networkClient: WorkoutsNetworkClientImpl())
}
