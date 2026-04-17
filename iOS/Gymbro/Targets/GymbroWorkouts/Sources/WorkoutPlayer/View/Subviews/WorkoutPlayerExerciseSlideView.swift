import SwiftUI

import GymbroCommonUI
import GymbroTypes

struct WorkoutPlayerExerciseSlideView: View {

    init(
        exercise: ExerciseItem,
        onNext: (() -> Void)?,
        onWeightChanged: ((Double) -> Void)?
    ) {
        self.exercise = exercise
        self.onNext = onNext
        self.onWeightChanged = onWeightChanged
        if case .strength(let e) = exercise {
            _selectedWeight = State(initialValue: e.weightKg)
        } else {
            _selectedWeight = State(initialValue: 0)
        }
    }
    
    let exercise: ExerciseItem
    let onNext: (() -> Void)?
    let onWeightChanged: ((Double) -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            header
            
            if case .cardio(let cardioExercise) = exercise {
                CardioTimerView(
                    durationSeconds: cardioExercise.durationMinutes * 60,
                    accentColor: exercise.accentColor,
                    onNext: onNext
                )
                .padding(.top, 8)
            }

            Spacer()

            icon

            Spacer()

            bottomStack

            if case .strength = exercise {
                WeightPickerView(weight: $selectedWeight, accentColor: exercise.accentColor)
                    .padding(.top, 8)
            }
            
        }
        .padding(.all, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(LinearGradient(
                    colors: [exercise.accentColor.opacity(0.5), Color.appDarkGray],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                        .strokeBorder(LinearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                )
        )
        .onChange(of: selectedWeight) { _, newWeight in
            if case .strength = exercise, let onWeightChanged {
                onWeightChanged(newWeight)
            }
        }
    }
    
    @State private var selectedWeight: Double

    @ViewBuilder
    private var header: some View {
        Text(exercise.name)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)

        Text(exercise.muscleGroup.localizedTitle)
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(exercise.accentColor.opacity(0.18))
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.appDarkGray.opacity(0.9), exercise.accentColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    @ViewBuilder
    private var icon: some View {
        switch exercise {
        case .strength:
            Image("strength", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

        case .cardio:
            Image("cardio", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)

        case .yoga:
            Image("yoga", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

        case .fallback:
            Image("cardio", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }

    @ViewBuilder
    private var bottomStack: some View {
        HStack(spacing: 8) {
            switch exercise {
            case .strength(let e):
                paramCapsule(title: String(localized: "workout.field.sets", bundle: .module), subtitle: "\(e.sets)")
                paramCapsule(title: String(localized: "workout.field.reps", bundle: .module), subtitle: "\(e.reps)")
                paramCapsule(title: String(localized: "workout.player.label_weight", bundle: .module), subtitle: formatKg(selectedWeight))
            case .cardio(let e):
                paramCapsule(title: String(localized: "workout.player.label_duration", bundle: .module), subtitle: "\(e.durationMinutes) min")
                paramCapsule(title: String(localized: "workout.field.pace", bundle: .module), subtitle: e.pace.localizedTitle)
            case .yoga(let e):
                paramCapsule(title: String(localized: "workout.player.breath_count", bundle: .module), subtitle: "\(e.breathCount)")
                paramCapsule(title: String(localized: "workout.player.hold_for", bundle: .module), subtitle: "\(e.holdSeconds) sec")
            case .fallback:
                EmptyView()
            }
        }
    }

    private func paramCapsule(title: String, subtitle: String) -> some View {
        VStack {
            Text(title)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.white)
                .animation(.easeInOut(duration: 0.2), value: subtitle)
        }
        .padding(.all, 10)
        .frame(maxWidth: .infinity)
        .background(
            Capsule(style: .continuous)
                .fill(exercise.accentColor.opacity(0.18))
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.appDarkGray.opacity(0.9), exercise.accentColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private func formatKg(_ kg: Double) -> String {
        kg.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(kg)) kg"
            : String(format: "%.1f kg", kg)
    }
}

// MARK: - Helpers

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
