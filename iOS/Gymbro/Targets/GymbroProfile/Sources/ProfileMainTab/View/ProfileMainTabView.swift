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
                Text(String(localized: "profile.loading", bundle: .module))
            case .loaded:
                VStack(spacing: 24) {
                    Text(String(localized: "profile.title", bundle: .module))
                        .font(.title)
                        .foregroundStyle(.white)
                    
                    AppButton(
                        viewModel.isLoggingOut ? String(localized: "profile.logging_out", bundle: .module) : String(localized: "profile.logout", bundle: .module),
                        size: .xl
                    ) {
                        viewModel.logout()
                    }
                }
                .padding(.horizontal, 24)
            case .error:
                VStack(alignment: .center) {
                    Text(GymbroCommonStrings.genericError)
                        .font(.title3)
                        .foregroundStyle(Color.white)
                    AppButton(GymbroCommonStrings.refresh, size: .xl) {
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

