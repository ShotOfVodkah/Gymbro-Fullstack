import Foundation

public enum WorkoutType {
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

public enum PaceType {
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

public enum MuscleGroup {
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

