import Foundation

public protocol WorkoutsNetworkClient {
    func fetchWorkouts() -> String
}

final class WorkoutsNetworkClientStub: WorkoutsNetworkClient {
    
    func fetchWorkouts() -> String {
        return "Stub"
    }
    
}
