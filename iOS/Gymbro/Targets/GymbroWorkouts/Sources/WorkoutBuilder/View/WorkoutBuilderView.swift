import SwiftUI

import GymbroCommonUI
import DivKit

struct WorkoutBuilderView: View {

    init(viewModel: WorkoutBuilderViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Group {
                switch viewModel.screenState {
                case .loading:
                    WorkoutBuilderViewStub()
                case .loaded:
                    DivHostingView(divkitComponents: viewModel.divkitComponents, source: viewModel.source!)
                        .overlay(alignment: .topLeading) {
                            UITestMarker(id: "workouts.builder.loaded")
                        }
                case .offline:
                    VStack{
                        OfflineHeader()
                        DivHostingView(divkitComponents: viewModel.divkitComponents, source: viewModel.source!)
                            .overlay(alignment: .topLeading) {
                                UITestMarker(id: "workouts.builder.loaded")
                            }
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                case .error:
                    VStack(alignment: .center) {
                        Text(GymbroCommonStrings.genericError)
                            .font(.title3)
                            .foregroundStyle(Color.white)
                        AppButton(GymbroCommonStrings.refresh, size: .xl) {
                            viewModel.fetchData()
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            Button {
                viewModel.backButtonTapped()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .imageScale(.large)
            }
            .accessibilityIdentifier("workouts.builder.back")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, viewModel.screenState == .offline ? 58 : 20)
            .padding(.leading, 16)
            
        }
        .sheet(item: $viewModel.sheetModel, onDismiss: {
            viewModel.sheetModel = nil
        }) { model in
           PremadeWorkoutSheet(model: model)
                .presentationDetents([.fraction(0.7)])
        }
        .customAlert(
            isPresented: $viewModel.showAlert,
            data: CustomAlertData(
                message: String(localized: "workout.builder.offline_generator", bundle: .module),
                primaryButton: AppButton(String(localized: "workout.builder.action_okay", bundle: .module), action: {
                    viewModel.showAlert = false
                })
            )
        )
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color.black.ignoresSafeArea(.all))
    }

    @ObservedObject private var viewModel: WorkoutBuilderViewModel
}
