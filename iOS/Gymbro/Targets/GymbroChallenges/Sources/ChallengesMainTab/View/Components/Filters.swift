import Foundation
import SwiftUI

enum ChallengeFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case joined = "joined"
    case available = "available"
    case inProgress = "in_progress"
    case completed = "completed"
    case failed = "failed"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .all:
            return String(localized: "challenges.filter.all", bundle: .module)
        case .joined:
            return String(localized: "challenges.filter.joined", bundle: .module)
        case .available:
            return String(localized: "challenges.filter.available", bundle: .module)
        case .inProgress:
            return String(localized: "challenges.filter.in_progress", bundle: .module)
        case .completed:
            return String(localized: "challenges.filter.completed", bundle: .module)
        case .failed:
            return String(localized: "challenges.filter.failed", bundle: .module)
        }
    }
}

enum ChallengeCategory: String, CaseIterable, Identifiable {
    case workouts = "workouts"
    case minutes = "minutes"
    case streak = "streak"
    case strength = "strength"
    case cardio = "cardio"
    case exercises = "exercises"
    case muscleGroups = "muscle_groups"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .workouts:
            return String(localized: "challenges.category.workouts", bundle: .module)
        case .minutes:
            return String(localized: "challenges.category.minutes", bundle: .module)
        case .streak:
            return String(localized: "challenges.category.streak", bundle: .module)
        case .strength:
            return String(localized: "challenges.category.strength", bundle: .module)
        case .cardio:
            return String(localized: "challenges.category.cardio", bundle: .module)
        case .exercises:
            return String(localized: "challenges.category.exercises", bundle: .module)
        case .muscleGroups:
            return String(localized: "challenges.category.muscle_groups", bundle: .module)
        }
    }

    var iconName: String {
        switch self {
        case .workouts: return "figure.strengthtraining.traditional"
        case .minutes: return "clock.fill"
        case .streak: return "flame.fill"
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .exercises: return "scope"
        case .muscleGroups: return "figure.highintensity.intervaltraining"
        }
    }
}
