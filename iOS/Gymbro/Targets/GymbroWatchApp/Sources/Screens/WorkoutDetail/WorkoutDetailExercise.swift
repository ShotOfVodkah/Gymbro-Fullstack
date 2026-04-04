import SwiftUI

struct ExerciseRowView: View {
    
    init(exercise: ExerciseItem, color: Color) {
        self.exercise = exercise
        self.color = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(exercise.name)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.all, 10)
        .background{
            LinearGradient(
                colors: [color.opacity(0.8), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .cornerRadius(10)
        }
    }
    
    private let exercise: ExerciseItem
    private let color: Color

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

