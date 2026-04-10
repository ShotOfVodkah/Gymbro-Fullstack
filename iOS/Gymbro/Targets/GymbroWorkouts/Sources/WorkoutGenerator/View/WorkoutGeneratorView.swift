import SwiftUI

import GymbroCommonUI
import GymbroTypes

struct WorkoutGeneratorView: View {

    init(viewModel: WorkoutGeneratorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TopGradientBackground()
            
            content
            
            Button {
                viewModel.exit()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .imageScale(.large)
            }
            .padding(.leading, 16)

        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
    }
    
    private var content: some View {
        VStack {
            AppButton("generate", action: {
                Task {
                    await viewModel.generateWorkout()
                }
            })
            
            if let workout = viewModel.generated {
                Text(workout.name)
                    .foregroundStyle(.white)
            }
        }
    }

    @ObservedObject private var viewModel: WorkoutGeneratorViewModel
}

extension ExerciseItem {
    fileprivate var accentColor: Color {
        switch self {
        case .strength: return Color.strengthColor
        case .cardio: return Color.cardioColor
        case .yoga: return Color.yogaColor
        case .fallback: return Color.appPurple
        }
    }
}
