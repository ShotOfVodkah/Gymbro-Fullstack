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

            Divider()

            exerciseContent

            Spacer()

            actionButton
        }
        .padding(.horizontal, 4)
        .navigationTitle("\(viewModel.currentIndex + 1)/\(viewModel.totalCount)")
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading) { backButton }
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
            .tint(.green)
            .padding(.top, 4)
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
        }
        .buttonStyle(.plain)
        .padding(.leading, 2)
        .padding(.top, 2)
    }

    @ViewBuilder
    private var exerciseContent: some View {
        let exercise = viewModel.currentExercise

        VStack(alignment: .leading, spacing: 6) {
            Text(exercise.name)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            switch exercise {
            case .strength:
                strengthControls
            case .cardio:
                EmptyView()
            case .yoga:
                yogaControls
            case .fallback:
                EmptyView()
            }
        }
    }

    private var strengthControls: some View {
        VStack(spacing: 4) {
            stepper(label: "Sets", value: $viewModel.sets, range: 1...20)
            stepper(label: "Reps", value: $viewModel.reps, range: 1...100)
            weightStepper
        }
    }

    private var weightStepper: some View {
        HStack {
            Text("Weight")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button { viewModel.weightKg = max(0, viewModel.weightKg - 2.5) } label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.plain)
            Text("\(viewModel.weightKg, specifier: "%.1f")")
                .font(.caption.monospacedDigit())
                .frame(minWidth: 36)
            Button { viewModel.weightKg += 2.5 } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
        }
    }

    private var yogaControls: some View {
        VStack(spacing: 4) {
            stepper(label: "Hold (s)", value: $viewModel.holdSeconds, range: 1...300)
            stepper(label: "Breaths", value: $viewModel.breathCount, range: 1...50)
        }
    }

    private func stepper(label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button { value.wrappedValue = max(range.lowerBound, value.wrappedValue - 1) } label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.plain)
            Text("\(value.wrappedValue)")
                .font(.caption.monospacedDigit())
                .frame(minWidth: 28)
            Button { value.wrappedValue = min(range.upperBound, value.wrappedValue + 1) } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
        }
    }

    private var actionButton: some View {
        Button(action: { viewModel.advanceOrFinish() }) {
            Text(viewModel.isLast ? "Finish" : "Next")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(viewModel.isLast ? .green : .blue)
    }

    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.green)
                Text("Saved!")
                    .font(.headline)
                Text("Syncing when iPhone is nearby")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
