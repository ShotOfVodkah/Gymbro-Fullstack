import SwiftUI

struct WorkoutDetailView: View {

    init(viewModel: WorkoutDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                typeLabel

                ForEach(viewModel.workout.exercises) { exercise in
                    ExerciseRowView(exercise: exercise, color: viewModel.workout.type.color)
                }

                NavigationLink {
                    WorkoutPlayerView(viewModel: viewModel.makePlayerViewModel())
                } label: {
                    Label(String(localized: "watch.workout.start", bundle: .module), systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .background(Color.appPurple)
                .clipShape(Capsule())
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(viewModel.workout.name)
    }
    
    @ObservedObject private var viewModel: WorkoutDetailViewModel

    private var typeLabel: some View {
        HStack(spacing: 2) {
            Text(viewModel.workout.type.title)
                .font(.caption)
                .foregroundStyle(viewModel.workout.type.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(viewModel.workout.type.color.opacity(0.2), in: Capsule())
    }
}
