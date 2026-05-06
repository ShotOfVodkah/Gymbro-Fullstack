import SwiftUI

import GymbroCommonUI
import GymbroTypes

struct WorkoutGeneratorView: View {

    init(viewModel: WorkoutGeneratorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                TopGradientBackground()
                
                Spacer()
                
                TopGradientBackground()
                    .rotationEffect(Angle(degrees: 180))
            }
            .ignoresSafeArea(.all)

            content

            HStack {
                Button {
                    viewModel.exit()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
                .accessibilityIdentifier("workouts.generator.back")
                .padding(.leading, 16)
                
                Text(String(localized: "workout.generator.title", bundle: .module))
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
            }
            .padding(.leading, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
        .overlay(alignment: .topLeading) {
            if viewModel.screenState == .loaded {
                UITestMarker(id: "workouts.generator.loaded")
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            AppTextField(
                title: String(localized: "workout.generator.field_prompt_title", bundle: .module),
                placeholder: "",
                text: $viewModel.prompt,
                textFieldAccessibilityIdentifier: "workouts.generator.prompt"
            )
            
            if viewModel.screenState == .loaded && viewModel.generated == nil {
                VStack(alignment: .leading, spacing: 24) {
                    injuriesSection

                    AppButton(String(localized: "workout.generator.action_generate", bundle: .module), size: .l, action: {
                        Task { await viewModel.generateWorkout() }
                    }, wrapContent: false)
                    .accessibilityIdentifier("workouts.generator.generate")
                }
            } else {
                resultSection
                    .frame(height: 500)
            }
        }
        .customAlert(
            isPresented: $viewModel.showAlert,
            data: CustomAlertData(
                message: String(localized: "workout.generator.alert_empty_prompt", bundle: .module),
                primaryButton: AppButton(
                    String(localized: "workout.builder.action_okay", bundle: .module),
                    action: { viewModel.showAlert = false }
                )
            )
        )
        .padding(.horizontal, 16)
        .animation(.easeInOut, value: viewModel.screenState == .loaded && viewModel.generated == nil)
        .frame(maxHeight: .infinity, alignment: .center)
    }

    private var injuriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "workout.generator.injuries_label", bundle: .module))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 8
            ) {
                ForEach(Injury.allCases, id: \.codingValue) { injury in
                    InjuryToggleChip(
                        label: injury.localizedTitle,
                        isSelected: viewModel.selectedInjuries.contains(injury),
                        action: { viewModel.toggleInjury(injury) }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        switch viewModel.screenState {
        case .loading:
            WorkoutLoadingCard()
        case .loaded:
            if let workout = viewModel.generated {
                WorkoutResultCard(
                    workout: workout,
                    dismissAction: viewModel.dismiss,
                    saveAction: viewModel.saveWorkout
                )
            }
        case .error:
            VStack {
                Text(String(localized: "workout.generator.error_prompt", bundle: .module))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                AppButton(
                    String(localized: "workout.builder.action_okay", bundle: .module),
                    action: viewModel.dismiss
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)
        case .offline:
            EmptyView()
        }
    }

    @ObservedObject private var viewModel: WorkoutGeneratorViewModel
}
