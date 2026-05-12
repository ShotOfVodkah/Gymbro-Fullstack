import Foundation
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
            return "\(e.sets)×\(e.reps) · \(Int(e.weightKg)) \(String(localized: "watch.field.kg", bundle: .module))"
        case .cardio(let e):
            let unit = String(localized: "watch.detail.min_abbr", bundle: .module)
            return String(
                format: String(localized: "watch.detail.cardio_line", bundle: .module),
                locale: .current,
                e.durationMinutes,
                unit,
                e.pace.title
            )
        case .yoga(let e):
            return "\(e.holdSeconds)s · \(e.breathCount) \(String(localized: "watch.field.breath", bundle: .module))"
        case .fallback:
            return ""
        }
    }
}

