import Foundation
import DivKit

final class WorkoutsListViewModel: ObservableObject {

    init(networkClient: WorkoutsNetworkClient) {
        self.networkClient = networkClient
    }

    func onAppear() {
        let jsonData = networkClient.fetchWorkoutsDivJson()
        source = DivViewSource(kind: .data(jsonData), cardId: "WorkoutsCard")
    }

    @Published var source: DivViewSource? = nil
    private let networkClient: WorkoutsNetworkClient
}

