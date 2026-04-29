import Foundation
import SwiftUI
import GymbroTypes

enum ChallengeFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case joined = "Joined"
    case available = "Available"
    case inProgress = "In Progress"
    case completed = "Completed"
    case failed = "Failed"
    
    var id: String { rawValue }
}

enum ChallengeCategory: String, CaseIterable, Identifiable {
    case workouts = "Workouts"
    case minutes = "Minutes"
    case streak = "Streak"
    case strength = "Strength"
    case cardio = "Cardio"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .workouts: return "figure.strengthtraining.traditional"
        case .minutes: return "clock.fill"
        case .streak: return "flame.fill"
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        }
    }
}
