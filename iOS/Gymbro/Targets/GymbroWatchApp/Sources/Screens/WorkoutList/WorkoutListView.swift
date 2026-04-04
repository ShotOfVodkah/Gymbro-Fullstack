import SwiftUI

struct WorkoutListView: View {

    @ObservedObject private var viewModel: WorkoutListViewModel

    init(viewModel: WorkoutListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.workouts.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .navigationTitle("Workouts")
    }

    // MARK: - Subviews

    private var list: some View {
        List(viewModel.workouts) { workout in
            NavigationLink(value: workout) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(workout.type.title)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationDestination(for: WatchWorkoutPayload.self) { workout in
            WorkoutDetailView(
                viewModel: WorkoutDetailViewModel(
                    workout: workout,
                    onSubmit: viewModel.submitSession
                )
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text("Open Gymbro on iPhone to sync workouts")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
