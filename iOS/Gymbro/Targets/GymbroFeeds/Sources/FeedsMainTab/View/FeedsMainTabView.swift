import Foundation
import SwiftUI
import GymbroCommonUI


struct FeedsMainTabView: View {
    
    init(viewModel: FeedsMainTabViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            switch viewModel.screenState {
            case .loading:
                FeedsViewStub()
                
            case .loaded:
                FeedsView(viewModel: viewModel)
                
            case .error:
                VStack(alignment: .center) {
                    Text("Something went wrong, oopsie...")
                        .font(.title3)
                        .foregroundStyle(Color.white)
                    AppButton("Refresh", size: .xl) {
                        viewModel.reload()
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
        .ignoresSafeArea(.container, edges: .bottom)
    }
    @ObservedObject private var viewModel: FeedsMainTabViewModel
}
