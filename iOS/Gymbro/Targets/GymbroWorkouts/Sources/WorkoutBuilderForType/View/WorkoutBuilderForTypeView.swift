import SwiftUI

import GymbroCommonUI
import GymbroTypes
import DivKit

struct WorkoutBuilderForTypeView: View {

    init(viewModel: WorkoutBuilderForTypeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Group {
                switch viewModel.screenState {
                case .loading:
                    WorkoutBuilderForTypeViewStub()
                case .loaded:
                    builderScreen
                case .offline:
                    VStack(spacing: 0){
                        OfflineHeader()
                        builderScreen
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                case .error:
                    VStack(alignment: .center) {
                        Text("Something went wrong, oopsie...")
                            .font(.title3)
                            .foregroundStyle(Color.white)
                        AppButton("Refresh", size: .xl) {
                            viewModel.fetchData(for: viewModel.type, workout: viewModel.workout)
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
            .padding(.top, viewModel.screenState == .offline ? 45 : 20)
            .padding(.leading, 16)
            
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color.black.ignoresSafeArea(.all))
        .customAlert(
            isPresented: $viewModel.showAlert,
            data: CustomAlertData(
                message: "So empty here... Make sure to add some exercises and name your workout before saving!",
                primaryButton: AppButton("Okay", action: { viewModel.showAlert.toggle() })
            )
        )
    }
    
    private var builderScreen: some View {
        ZStack(alignment: .bottom) {

            TopGradientBackground()

            VStack(alignment: .leading, spacing: 0) {

                BuilderHeaderView(
                    title: "\(viewModel.type) workout",
                    name: $viewModel.name
                )

                List {
                    ForEach($viewModel.selectedExercises) { $exercise in
                        ExerciseCardView(exercise: $exercise)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.black)
                    }
                    .onMove { from, to in
                        viewModel.selectedExercises.move(fromOffsets: from, toOffset: to)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 70)

                AvailableExercisesSection(
                    isCollapsed: $isCollapsed,
                    divkitComponents: viewModel.divkitComponents,
                    source: viewModel.source!
                )
            }

            AppButton(
                "Save",
                size: .xl,
                action: { viewModel.saveButtonTapped() },
                wrapContent: false
            )
            .padding(.bottom, 30)
            .padding(.horizontal, 8)
        }
    }
    
    @State private var isCollapsed: Bool = false
    @ObservedObject private var viewModel: WorkoutBuilderForTypeViewModel
}
