import SwiftUI

struct ExerciseInfoView: View {
    
    init(
        exercise: ExerciseItem,
        color: Color
    ) {
        self.exercise = exercise
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(exercise.name)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.2), in: Capsule())
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 2) {
                switch exercise {
                case .cardio(let e):
                    CardioTimerView(
                        durationSeconds: e.durationMinutes * 60,
                        accentColor: color
                    )
                    .id(exercise.id)
                case .strength(let e):
                    dataCapsule(title: "Sets", data: "\(e.sets)")
                    dataCapsule(title: "Reps", data: "\(e.reps)")
                    dataCapsule(title: "Kg", data: "\(e.weightKg)")
                case .yoga(let e):
                    dataCapsule(title: "Breath", data: "\(e.breathCount)")
                    dataCapsule(title: "Hold", data: "\(e.holdSeconds)")
                case .fallback(_):
                    EmptyView()
                }
            }
        }
    }
    
    private let exercise: ExerciseItem
    private let color: Color
    
    private func dataCapsule(title: String, data: String) -> some View {
        VStack {
            Text(title)
            Text(data)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.2), in: Capsule())
    }
    
}

