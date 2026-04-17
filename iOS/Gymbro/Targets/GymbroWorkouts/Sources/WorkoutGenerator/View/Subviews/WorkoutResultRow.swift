import Foundation
import SwiftUI

import GymbroTypes

struct WorkoutResultRow: View {
    
    init(
        item: ExerciseItem
    ) {
        self.item = item
    }

    var body: some View {
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(item.muscleGroup.localizedTitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))

                    if let detail = detailText {
                        Text("·")
                            .foregroundStyle(.white.opacity(0.3))
                        Text(detail)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }

            }
            .padding(.vertical, 10)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.35), Color.appDarkGray.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                )
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private let item: ExerciseItem

    private var accentColor: Color {
        switch item {
        case .strength: return .strengthColor
        case .cardio: return .cardioColor
        case .yoga: return .yogaColor
        case .fallback: return .appPurple
        }
    }

    private var detailText: String? {
        switch item {
        case .strength(let e):
            let weight: String
            if e.weightKg == 0 {
                weight = String(localized: "workout.result.bodyweight", bundle: .module)
            } else {
                weight = "\(Int(e.weightKg)) \(String(localized: "workout.field.kg", bundle: .module))"
            }
            let fmt = String(localized: "workout.detail.strength", bundle: .module)
            return String(format: fmt, locale: .current, "\(e.sets)", "\(e.reps)", weight)
        case .cardio(let e):
            let fmt = String(localized: "workout.detail.cardio", bundle: .module)
            return String(format: fmt, locale: .current, "\(e.durationMinutes)", e.pace.localizedTitle)
        case .yoga(let e):
            let fmt = String(localized: "workout.detail.yoga", bundle: .module)
            return String(format: fmt, locale: .current, "\(e.holdSeconds)", "\(e.breathCount)")
        case .fallback:
            return nil
        }
    }
}


