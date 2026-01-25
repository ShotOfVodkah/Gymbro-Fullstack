import Foundation
import DivKit

import Foundation
import DivKit

@MainActor
final class WorkoutsListViewModel: ObservableObject {
    
    init(networkClient: WorkoutsNetworkClient) {
        self.networkClient = networkClient
    }
    
    func onAppear() {
        Task {
            do {
                let data = try await networkClient.fetchWorkoutsDivJson()
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
            } catch {
                let fallback = """
                {
                  "card": {
                    "log_id": "error",
                    "states": [
                      { "state_id": 0, "div": { "type": "text", "text": "Load error: \(error)" } }
                    ]
                  }
                }
                """
                source = DivViewSource(kind: .data(Data(fallback.utf8)), cardId: "WorkoutsCard")
            }
        }
    }
    
    @Published var source: DivViewSource? = nil
    private let networkClient: WorkoutsNetworkClient
}

