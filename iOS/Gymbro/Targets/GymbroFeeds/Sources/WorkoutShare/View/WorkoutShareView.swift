import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct WorkoutShareView: View {
    
    init(viewModel: WorkoutShareViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            switch viewModel.screenState {
            case .loading:
                WorkoutShareViewStub()
                
            case .loaded:
                ZStack {
                    contentView
                        .opacity(viewModel.isShowingSuccessState ? 0 : 1)
                        .scaleEffect(viewModel.isShowingSuccessState ? 0.985 : 1)
                    
                    if let summary = viewModel.deliverySummary, viewModel.isShowingSuccessState {
                        WorkoutShareSuccessView(
                            summary: summary,
                            onDoneTap: viewModel.finishSuccessFlow
                        )
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            )
                        )
                    }
                }
                .overlay(alignment: .topLeading) {
                    UITestMarker(id: "workouts.share.loaded")
                }
                
            case .offline:
                VStack(spacing: 0) {
                    OfflineHeader()
                    
                    ZStack {
                        contentView
                            .opacity(viewModel.isShowingSuccessState ? 0 : 1)
                            .scaleEffect(viewModel.isShowingSuccessState ? 0.985 : 1)
                        
                        if let summary = viewModel.deliverySummary, viewModel.isShowingSuccessState {
                            WorkoutShareSuccessView(
                                summary: summary,
                                onDoneTap: viewModel.finishSuccessFlow
                            )
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                )
                            )
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        UITestMarker(id: "workouts.share.loaded")
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
                
            case .error:
                WorkoutShareErrorStateView(onRetry: viewModel.reload)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            if (viewModel.screenState == .loaded || viewModel.screenState == .offline),
               !viewModel.isShowingSuccessState {
                WorkoutShareActionBar(
                    backButtonTitle: viewModel.backButtonTitle,
                    primaryButtonTitle: viewModel.primaryButtonTitle,
                    isPrimaryDisabled: viewModel.shouldDisablePrimaryButton,
                    onBackTap: viewModel.back,
                    onPrimaryTap: viewModel.handlePrimaryAction
                )
                .background(Color.clear)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.88), value: viewModel.isShowingSuccessState)
        .customAlert(
            isPresented: $viewModel.showSubmitError,
            data: CustomAlertData(
                message: viewModel.submitErrorMessage,
                primaryButton: AppButton("OK") {
                    viewModel.showSubmitError = false
                }
            )
        )
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            WorkoutShareHeader(
                title: viewModel.stepTitle,
                subtitle: viewModel.stepSubtitle,
            )
            .padding(.horizontal, 16)
            .padding(.top, 20)

            WorkoutShareStepIndicator(
                currentStepIndex: viewModel.currentStepIndex,
                totalSteps: viewModel.totalSteps,
                progressValue: viewModel.progressValue
            )
            .padding(.horizontal, 16)
            .padding(.top, 18)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    WorkoutShareSessionSummaryCard(
                        title: viewModel.summaryTitle,
                        subtitle: viewModel.summarySubtitle,
                    )
                    
                    stepContent
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 140)
            }
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .recipients:
            WorkoutShareRecipientsStepView(viewModel: viewModel)
            
        case .details:
            WorkoutShareDetailsStepView(viewModel: viewModel)
            
        case .preview:
            WorkoutSharePreviewStepView(viewModel: viewModel)
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12.0 / 255.0, green: 18.0 / 255.0, blue: 36.0 / 255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ObservedObject private var viewModel: WorkoutShareViewModel
}
