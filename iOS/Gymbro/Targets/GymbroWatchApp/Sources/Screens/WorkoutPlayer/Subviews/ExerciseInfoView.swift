import Foundation
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
                    dataCapsule(title: String(localized: "watch.field.sets", bundle: .module), data: "\(e.sets)")
                    dataCapsule(title: String(localized: "watch.field.reps", bundle: .module), data: "\(e.reps)")
                    dataCapsule(title: String(localized: "watch.field.kg", bundle: .module), data: "\(e.weightKg)")
                case .yoga(let e):
                    dataCapsule(title: String(localized: "watch.field.breath", bundle: .module), data: "\(e.breathCount)")
                    dataCapsule(title: String(localized: "watch.field.hold", bundle: .module), data: "\(e.holdSeconds)")
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

