import Foundation
import SwiftUI

import GymbroNetwork

public final class WorkoutsFactory {

    public init() { }

//    public func makeWorkoutsScreen(with networkClient: NetworkClient) -> some View {
//        let workoutsNetworkClient = WorkoutsNetworkClientStub(networkClient: networkClient)
    public func makeWorkoutsScreen() -> some View {
        let workoutsNetworkClient = WorkoutsNetworkClientStub()
        let viewModel = WorkoutsListViewModel(networkClient: workoutsNetworkClient)
        let view = WorkoutsListView(viewModel: viewModel)
        return view
    }
}

