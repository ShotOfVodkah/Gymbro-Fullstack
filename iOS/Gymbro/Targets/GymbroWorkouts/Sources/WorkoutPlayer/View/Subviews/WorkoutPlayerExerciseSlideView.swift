import SwiftUI

import GymbroCommonUI
import GymbroTypes

struct WorkoutPlayerExerciseSlideView: View {

    let exercise: ExerciseItem
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            header
            
            if case .cardio(let cardioExercise) = exercise {
                CardioTimerView(
                    durationSeconds: cardioExercise.durationMinutes * 60,
                    accentColor: exercise.accentColor,
                    onNext: action
                )
            }

            Spacer()

            icon

            Spacer()

            bottomStack
            
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
    }

    // MARK: - UI Components

    @ViewBuilder
    private var header: some View {
        Text(exercise.name)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)

        Text(exercise.muscleGroup.title)
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
            case .strength(let exercise):
                paramCapsule(title: "Sets", subtitle: "\(exercise.sets)")
                paramCapsule(title: "Reps", subtitle: "\(exercise.reps)")
                paramCapsule(title: "Weight", subtitle: "\(exercise.weightKg)")
            case .cardio(let exercise):
                paramCapsule(title: "Duration", subtitle: "\(exercise.durationMinutes) min")
                paramCapsule(title: "Pace", subtitle: exercise.pace.title)
            case .yoga(let exercise):
                paramCapsule(title: "Breath Count", subtitle: "\(exercise.breathCount)")
                paramCapsule(title: "Hold for", subtitle: "\(exercise.holdSeconds) sec")
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
