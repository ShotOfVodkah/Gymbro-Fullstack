import Foundation
import SwiftUI
import DivKit

import GymbroTypes
import GymbroCommonUI

struct WorkoutInfoView: View {
    
    init(
        viewModel: WorkoutInfoViewModel,
        id: String,
        type: WorkoutInfoType
    ) {
        self.viewModel = viewModel
        self.id = id
        self.type = type
    }

    var body: some View {
        ZStack {
            Group {
                switch viewModel.screenState {
                case .loading:
                    WorkoutInfoViewStub()
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
                            viewModel.fetchData(with: id, type: type)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, viewModel.screenState == .offline ? 50 : 16)
            .padding(.leading, 16)
        }
        .customAlert(
            isPresented: $viewModel.showDeleteAlert,
            data: CustomAlertData(
                message: "Are you sure you want to delete this workout?",
                primaryButton: AppButton("Delete", action: {
                    viewModel.showDeleteAlert = false
                    viewModel.deleteCurrentWorkout()
                })
            )
        )
        .customAlert(
            isPresented: $viewModel.showAddAlert,
            data: CustomAlertData(
                message: "There was an error adding this workout",
                primaryButton: AppButton("Oh.. Ok", action: {
                    viewModel.showAddAlert = false
                })
            )
        )
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
        .ignoresSafeArea(.container, edges: .bottom)
    }

    @ObservedObject private var viewModel: WorkoutInfoViewModel
    private let id: String
    private let type: WorkoutInfoType
}
