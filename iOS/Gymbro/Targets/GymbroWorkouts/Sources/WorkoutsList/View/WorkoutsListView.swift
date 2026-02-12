import SwiftUI

import GymbroCommonUI
import DivKit

struct WorkoutsListView: View {

    init(viewModel: WorkoutsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            switch viewModel.screenState {
            case .loading:
                WorkoutsListViewStub()
            case .loaded:
                DivHostingView(divkitComponents: viewModel.divkitComponents, source: viewModel.source!)
            case .offline:
                VStack{
                    OfflineHeader()
                    DivHostingView(divkitComponents: viewModel.divkitComponents, source: viewModel.source!)
                }
            case .error:
                VStack(alignment: .center) {
                    Text("Something went wrong, oopsie...")
                        .font(.title3)
                        .foregroundStyle(Color.white)
                    AppButton("Refresh", size: .xl) {
                        viewModel.fetchData()
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .customAlert(
            isPresented: $viewModel.showOfflineAlert,
            data: CustomAlertData(
                message: "You are currently offline. Some actions are limited.",
                primaryButton: AppButton("Okay", action: {
                    viewModel.showOfflineAlert = false
                })
            )
        )
        .sheet(item: $viewModel.streakModel, onDismiss: {
            viewModel.streakModel = nil
        }) { model in
            WorkoutsStreakSheet(
                total: model.goal,
                current: model.current,
                daysLeft: model.daysLeft,
                value: model.value
            )
                .presentationDetents([.fraction(0.4)])
        }
        .transition(.blurReplace)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
    }

    @ObservedObject private var viewModel: WorkoutsListViewModel
}
