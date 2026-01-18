import Foundation
import SwiftUI

public final class WorkoutsFactory {
    
    public init(networkClient: WorkoutsNetworkClient) {
        self.networkClient = networkClient
    }
    
    public func makeWorkoutsScreen() -> some View {
        let viewModel = WorkoutsListViewModel(networkClient: networkClient)
        let view = WorkoutsListView(viewModel: viewModel)
        return view
    }
    
    private let networkClient: WorkoutsNetworkClient
}
