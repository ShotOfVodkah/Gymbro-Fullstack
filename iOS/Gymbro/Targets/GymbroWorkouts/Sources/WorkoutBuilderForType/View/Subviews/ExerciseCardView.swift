import SwiftUI
import GymbroTypes
import GymbroCommonUI

struct ExerciseCardView: View {
    @Binding var exercise: ExerciseItem

    var body: some View {
        let accent = exerciseAccentColor(exercise)

        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appDarkGray.opacity(0.9), accent],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8)
                .padding(.vertical, 10)

            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                pickerSection
            }
            .padding(.vertical, 12)

            Spacer(minLength: 0)

            Image(systemName: "line.3.horizontal")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 7)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appDarkGray)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var pickerSection: some View {
        switch exercise {
        case .cardio:
            CardioInputsView(duration: cardioDurationBinding, pace: cardioPaceBinding)

        case .yoga:
            YogaInputsView(holdSeconds: yogaHoldBinding, breathCount: yogaBreathBinding)

        case .strength:
            StrengthInputsView(sets: strengthSetsBinding, reps: strengthRepsBinding, weightKg: strengthWeightBinding)

        case .fallback:
            EmptyView()
        }
    }
}

// MARK: - Helpers

extension ExerciseCardView {

    // MARK: - Cardio bindings

    var cardioDurationBinding: Binding<Int> {
        Binding(
            get: { if case .cardio(let e) = exercise { e.durationMinutes } else { 0 } },
            set: { newValue in
                guard case .cardio(let e) = exercise else { return }
                exercise = .cardio(.init(
                    id: e.id, name: e.name, muscleGroup: e.muscleGroup,
                    durationMinutes: newValue, pace: e.pace
                ))
            }
        )
    }

    var cardioPaceBinding: Binding<PaceType> {
        Binding(
            get: { if case .cardio(let e) = exercise { e.pace } else { PaceType.allCases.first! } },
            set: { newValue in
                guard case .cardio(let e) = exercise else { return }
                exercise = .cardio(.init(
                    id: e.id, name: e.name, muscleGroup: e.muscleGroup,
                    durationMinutes: e.durationMinutes, pace: newValue
                ))
            }
        )
    }

    // MARK: - Yoga bindings

    var yogaHoldBinding: Binding<Int> {
        Binding(
            get: { if case .yoga(let e) = exercise { e.holdSeconds } else { 0 } },
            set: { newValue in
                guard case .yoga(let e) = exercise else { return }
                exercise = .yoga(.init(
                    id: e.id, name: e.name, muscleGroup: e.muscleGroup,
                    holdSeconds: newValue, breathCount: e.breathCount
                ))
            }
        )
    }

    var yogaBreathBinding: Binding<Int> {
        Binding(
            get: { if case .yoga(let e) = exercise { e.breathCount } else { 0 } },
            set: { newValue in
                guard case .yoga(let e) = exercise else { return }
                exercise = .yoga(.init(
                    id: e.id, name: e.name, muscleGroup: e.muscleGroup,
                    holdSeconds: e.holdSeconds, breathCount: newValue
                ))
            }
        )
    }

    // MARK: - Strength bindings

    var strengthSetsBinding: Binding<Int> {
        Binding(
            get: { if case .strength(let e) = exercise { e.sets } else { 0 } },
            set: { newValue in
                guard case .strength(let e) = exercise else { return }
                exercise = .strength(.init(
                    id: e.id, name: e.name, muscleGroup: e.muscleGroup,
                    sets: newValue, reps: e.reps, weightKg: e.weightKg
                ))
            }
        )
    }

    var strengthRepsBinding: Binding<Int> {
        Binding(
            get: { if case .strength(let e) = exercise { e.reps } else { 0 } },
            set: { newValue in
                guard case .strength(let e) = exercise else { return }
                exercise = .strength(.init(
                    id: e.id, name: e.name, muscleGroup: e.muscleGroup,
                    sets: e.sets, reps: newValue, weightKg: e.weightKg
                ))
            }
        )
    }

    var strengthWeightBinding: Binding<Double> {
        Binding(
            get: { if case .strength(let e) = exercise { e.weightKg } else { 0 } },
            set: { newValue in
                guard case .strength(let e) = exercise else { return }
                exercise = .strength(.init(
                    id: e.id, name: e.name, muscleGroup: e.muscleGroup,
                    sets: e.sets, reps: e.reps, weightKg: newValue
                ))
            }
        )
    }

    // MARK: - Accent

    func exerciseAccentColor(_ exercise: ExerciseItem) -> Color {
        switch exercise {
        case .strength: return .strengthColor
        case .cardio: return .cardioColor
        case .yoga: return .yogaColor
        case .fallback: return .appPurple
        }
    }
}

