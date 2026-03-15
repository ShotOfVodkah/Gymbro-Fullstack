import Foundation
import SwiftUI

import GymbroCommonUI


struct ProfileMainTabView: View {
    
    init(viewModel: ProfileMainTabViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            switch viewModel.screenState {
            case .loading:
                Text("loading")
            case .loaded:
                VStack(spacing: 24) {
                    Text("Profile")
                        .font(.title)
                        .foregroundStyle(.white)
                    
                    AppButton(
                        viewModel.isLoggingOut ? "Logging out..." : "Log out",
                        size: .xl
                    ) {
                        viewModel.logout()
                    }
                }
                .padding(.horizontal, 24)
            case .error:
                VStack(alignment: .center) {
                    Text("Something went wrong, oopsie...")
                        .font(.title3)
                        .foregroundStyle(Color.white)
                    AppButton("Refresh", size: .xl) {
                        // TODO Refresh
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    @ObservedObject private var viewModel: ProfileMainTabViewModel
}

