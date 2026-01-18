import Foundation

final class WorkoutsListViewModel: ObservableObject {
    
    init(networkClient: WorkoutsNetworkClient) {
        self.networkClient = networkClient
    }
    
    func onAppear() {
        exampleText = networkClient.fetchWorkouts()
    }
    
    @Published var exampleText: String = "Loading"
    
    private let networkClient: WorkoutsNetworkClient
}
