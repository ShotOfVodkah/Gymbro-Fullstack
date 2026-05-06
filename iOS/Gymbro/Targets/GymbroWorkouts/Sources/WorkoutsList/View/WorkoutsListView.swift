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
                        .id(viewModel.sourceDebugId)
                        .overlay(alignment: .topLeading) {
                            UITestMarker(id: "workouts.list.loaded")
                        }
                case .offline:
                    VStack{
                        OfflineHeader()
                        DivHostingView(divkitComponents: viewModel.divkitComponents, source: viewModel.source!)
                            .id(viewModel.sourceDebugId)
                            .overlay(alignment: .topLeading) {
                                UITestMarker(id: "workouts.list.loaded")
                            }
                    }
            case .error:
                VStack(alignment: .center) {
                    Text(GymbroCommonStrings.genericError)
                        .font(.title3)
                        .foregroundStyle(Color.white)
                    AppButton(GymbroCommonStrings.refresh, size: .xl) {
                        viewModel.screenState = .loading
                        viewModel.fetchData()
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .sheet(item: $viewModel.streakModel, onDismiss: {
            viewModel.streakModel = nil
        }) { model in
            WorkoutsStreakSheet(
                total: model.goal,
                current: model.current,
                daysLeft: model.daysLeft,
                value: model.value,
                wasFreezeUsedThisWeek: model.wasFreezeUsedThisWeek,
                isGoalCompleted: model.isGoalCompleted
            )
                .presentationDetents([.fraction(0.6)])
        }
        .transition(.blurReplace)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
        .ignoresSafeArea(.container, edges: .bottom)
    }

    @ObservedObject private var viewModel: WorkoutsListViewModel
}
