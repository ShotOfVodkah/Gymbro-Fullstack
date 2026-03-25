import Foundation
import SwiftUI

public enum ExerciseItem: Identifiable, Equatable {
    case strength(StrengthExercise)
    case cardio(CardioExercise)
    case yoga(YogaExercise)
    case fallback(DefaultExercise)
    
    public init(from exercise: any Exercise) {
        switch exercise {
        case let e as StrengthExercise:
            self = .strength(e)
            
        case let e as CardioExercise:
            self = .cardio(e)
                
        case let e as YogaExercise:
            self = .yoga(e)
                
        case let e as DefaultExercise:
            self = .fallback(e)
            
        default:
            fatalError("Unsupported Exercise type: \(type(of: exercise))")
        }
    }

    public  var id: String {
        switch self {
        case .strength(let e): return e.id
        case .cardio(let e): return e.id
        case .yoga(let e): return e.id
        case .fallback(let e): return e.id
        }
    }

    public var name: String {
        switch self {
        case .strength(let e): return e.name
        case .cardio(let e): return e.name
        case .yoga(let e): return e.name
        case .fallback(let e): return e.name
        }
    }
    
    public var muscleGroup: MuscleGroup {
        switch self {
        case .strength(let e): return e.muscleGroup
        case .cardio(let e): return e.muscleGroup
        case .yoga(let e): return e.muscleGroup
        case .fallback(let e): return e.muscleGroup
        }
    }
    
    public var exercise: any Exercise {
        switch self {
        case .strength(let e):
            return e
        case .cardio(let e):
            return e
        case .yoga(let e):
            return e
        case .fallback(let e):
            return e
        }
    }    
}

public enum WorkoutType: Codable {
    case strength
    case cardio
    case yoga
    
    public var title: String {
        switch self {
        case .strength: return "Strength"
        case .cardio: return "Cardio"
        case .yoga: return "Yoga"
        }
    }
    
    public var style: WorkoutStyle {
        switch self {
        case .strength:
            return WorkoutStyle(
                headerGradientStart: "#2E27FF",
                headerGradientEnd: "#732AFF",
                exerciseGradientColor: "#2E27FF",
                iconUrl: "http://localhost:8080/assets/strength.png"
            )
        case .cardio:
            return WorkoutStyle(
                headerGradientStart: "#BC31CF",
                headerGradientEnd: "#732AFF",
                exerciseGradientColor: "#BC31CF",
                iconUrl: "http://localhost:8080/assets/cardio.png"
            )
        case .yoga:
            return WorkoutStyle(
                headerGradientStart: "#73FF7A",
                headerGradientEnd: "#732AFF",
                exerciseGradientColor: "#73FF7A",
                iconUrl: "http://localhost:8080/assets/yoga.png"
            )
        }
    }
}

public enum PaceType: CaseIterable, Hashable, Codable {
    case walk, jog, run, sprint, recovery
    
    public var title: String {
        switch self {
        case .walk: return "Walk"
        case .jog: return "Jog"
        case .run: return "Run"
        case .sprint: return "Sprint"
        case .recovery: return "Recovery"
        }
    }
}

public enum MuscleGroup: Codable {
    case chest, back, shoulders, biceps, triceps, legs, glutes, core, fullBody
    
    public var title: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .legs: return "Legs"
        case .glutes: return "Glutes"
        case .core: return "Core"
        case .fullBody: return "Full body"
        }
    }
}

// MARK: - Styles
public struct WorkoutStyle {
    public let headerGradientStart: String
    public let headerGradientEnd: String
    public let exerciseGradientColor: String
    public let iconUrl: String
}

