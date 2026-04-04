import SwiftUI

struct WorkoutDetailView: View {

    @ObservedObject private var viewModel: WorkoutDetailViewModel

    init(viewModel: WorkoutDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                typeLabel

                Divider()

                ForEach(viewModel.workout.exercises) { exercise in
                    ExerciseRowView(exercise: exercise)
                }

                NavigationLink {
                    WorkoutPlayerView(viewModel: viewModel.makePlayerViewModel())
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(viewModel.workout.name)
    }

    private var typeLabel: some View {
        Text(viewModel.workout.type.title)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.tint.opacity(0.2), in: Capsule())
            .foregroundStyle(.tint)
    }
}

// MARK: - Exercise row

private struct ExerciseRowView: View {

    let exercise: ExerciseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(exercise.name)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var subtitle: String {
        switch exercise {
        case .strength(let e):
            return "\(e.sets) sets × \(e.reps) reps · \(e.weightKg) kg"
        case .cardio(let e):
            return "\(e.durationMinutes) min · \(e.pace.title)"
        case .yoga(let e):
            return "\(e.holdSeconds)s hold · \(e.breathCount) breaths"
        case .fallback:
            return ""
        }
    }
}
