import SwiftUI

struct WorkoutPlayerView: View {

    @StateObject private var viewModel: WorkoutPlayerViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: WorkoutPlayerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 8) {
            progressHeader

            ExerciseInfoView(
                exercise: viewModel.currentExercise,
                color: viewModel.workout.type.color
            )

            Spacer()

            actionButton
        }
        .padding(.horizontal, 4)
        .navigationTitle(viewModel.workout.name)
        .overlay {
            if viewModel.showFinishConfirmation {
                confirmationOverlay
            }
        }
        .onChange(of: viewModel.showFinishConfirmation) { submitted in
            if submitted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Subviews

    private var progressHeader: some View {
        ProgressView(value: Double(viewModel.currentIndex + 1), total: Double(viewModel.totalCount))
            .tint(
                viewModel.currentIndex + 1 == viewModel.totalCount
                ? .green
                : viewModel.workout.type.color
            )
            .padding(.top, 4)
            .animation(.linear(duration: 0.5), value: viewModel.currentIndex)
    }
    
    private var actionButton: some View {
        Button(action: { viewModel.advanceOrFinish() }) {
            Text(viewModel.isLast ? String(localized: "watch.player.finish", bundle: .module) : String(localized: "watch.player.next", bundle: .module))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(viewModel.isLast ? .appPurple : viewModel.workout.type.color)
    }

    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.green)
                Text(String(localized: "watch.workout.saved", bundle: .module))
                    .font(.headline)
                Text(String(localized: "watch.workout.sync_hint", bundle: .module))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
