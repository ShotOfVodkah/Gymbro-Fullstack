import SwiftUI

struct WorkoutsListView: View {
    
    init(viewModel: WorkoutsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text(viewModel.exampleText)
            .onAppear {
                viewModel.onAppear()
            }
    }
    
    @ObservedObject private var viewModel: WorkoutsListViewModel
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsListView(viewModel: WorkoutsListViewModel(networkClient: WorkoutsNetworkClientStub()))
    }
}
