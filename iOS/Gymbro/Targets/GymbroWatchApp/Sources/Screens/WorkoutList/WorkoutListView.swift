import SwiftUI

struct WorkoutListView: View {

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
        .navigationTitle(String(localized: "watch.workouts.title", bundle: .module))
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
                .padding(.leading, 10)
            }
            .listRowBackground(
                LinearGradient(
                    colors: [.appDarkGray, workout.type.color],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(10)
            )
            .listRowInsets(EdgeInsets())
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
    
    @ObservedObject private var viewModel: WorkoutListViewModel

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 28))
                .foregroundStyle(Color.appPurple)
            Text(String(localized: "watch.workouts.sync_hint", bundle: .module))
                .font(.footnote)
                .foregroundStyle(Color.appPurple)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
