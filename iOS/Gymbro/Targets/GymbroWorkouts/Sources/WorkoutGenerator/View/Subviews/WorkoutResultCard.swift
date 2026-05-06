import SwiftUI
import GymbroTypes
import GymbroCommonUI

struct WorkoutResultCard: View {
    
    init(
        workout: Workout,
        dismissAction: @escaping () -> Void,
        saveAction: @escaping () -> Void
    ) {
        self.workout = workout
        self.dismissAction = dismissAction
        self.saveAction = saveAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            exercisesList
            AppButton(String(localized: "workout.generator.action_save", bundle: .module), action: saveAction, wrapContent: false)
                .accessibilityIdentifier("workouts.generator.result.save")
                .padding(.horizontal, 40)
            Text(String(localized: "workout.generator.disclaimer", bundle: .module))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appDarkGray.opacity(0.85), typeColor(workout.type).opacity(0.25)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(typeColor(workout.type).opacity(0.1), lineWidth: 2)
                )
        )
    }
    
    private let workout: Workout
    private let dismissAction: () -> Void
    private let saveAction: () -> Void

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(workout.name)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Spacer(minLength: 0)

            Text(workout.type.localizedTitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(typeColor(workout.type).opacity(0.25))
                        .overlay(
                            Capsule()
                                .strokeBorder(typeColor(workout.type).opacity(0.6), lineWidth: 1)
                        )
                )
            
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .onTapGesture {
                    dismissAction()
                }
        }
    }

    private var exercisesList: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(workout.exercises.map { ExerciseItem(from: $0) }) { item in
                    WorkoutResultRow(item: item)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func typeColor(_ type: WorkoutType) -> Color {
        switch type {
        case .strength: return .strengthColor
        case .cardio: return .cardioColor
        case .yoga: return .yogaColor
        }
    }
}
