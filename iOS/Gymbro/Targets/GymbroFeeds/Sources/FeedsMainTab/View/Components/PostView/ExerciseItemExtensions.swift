import GymbroTypes
import SwiftUI

struct ExerciseMetaTagView: View {
    
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.6))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: 1)
            )
    }
}

extension ExerciseItem {
    
    var title: String {
        name
    }
    
    var subtitle: String {
        switch self {
        case .strength(let exercise):
            return "\(exercise.sets)x\(exercise.reps) • \(Int(exercise.weightKg)) kg"
            
        case .cardio(let exercise):
            return "\(exercise.durationMinutes) min • \(exercise.pace.localizedTitle)"
            
        case .yoga(let exercise):
            return "\(exercise.holdSeconds) sec • \(exercise.breathCount) breaths"
            
        case .fallback(let exercise):
            return exercise.muscleGroup.localizedTitle
        }
    }
    
    var imageName: String {
        switch self {
        case .strength:
            return "figure.strengthtraining.traditional"
        case .cardio:
            return "figure.run"
        case .yoga:
            return "figure.yoga"
        case .fallback:
            return "dumbbell.fill"
        }
    }
    
    var muscleGroupTitle: String {
        switch self {
        case .strength(let exercise):
            return exercise.muscleGroup.localizedTitle
        case .cardio(let exercise):
            return exercise.muscleGroup.localizedTitle
        case .yoga(let exercise):
            return exercise.muscleGroup.localizedTitle
        case .fallback(let exercise):
            return exercise.muscleGroup.localizedTitle
        }
    }
    
    var typeTitle: String {
        localizedTypeTitle
    }
    
    var accentColor: Color {
        switch self {
        case .strength:
            return .strengthColor
        case .cardio:
            return .cardioColor
        case .yoga:
            return .yogaColor
        case .fallback:
            return .appDarkGray
        }
    }
}
