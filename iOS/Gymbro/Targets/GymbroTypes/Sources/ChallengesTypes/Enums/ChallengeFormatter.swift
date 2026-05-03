import Foundation

enum ChallengeFormatter {
    
    static func progressText(
        current: Int,
        target: Int,
        unit: String
    ) -> String {
        "\(current)/\(target) \(formattedUnit(unit, value: target))"
    }
    
    static func dateText(endDate: Date) -> String {
        "Until \(endDate.formatted(date: .abbreviated, time: .omitted))"
    }
    
    static func timeLeftText(endDate: Date) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: endDate)
        let days = max(calendar.dateComponents([.day], from: start, to: end).day ?? 0, 0)
        
        if days == 0 {
            return "Ends today"
        }
        
        if days == 1 {
            return "Ends tomorrow"
        }
        
        return "Ends in \(days) days"
    }
    
    static func formattedUnit(_ unit: String, value: Int) -> String {
        switch ChallengeUnit(rawValue: unit) {
        case .workouts:
            return value == 1 ? "workout" : "workouts"
        case .minutes:
            return "minutes"
        case .calories:
            return "calories"
        case .days:
            return value == 1 ? "day" : "days"
        }
    }
    
    static func targetText(type: ChallengeType, targetFilter: String?) -> String? {
        guard let targetFilter, !targetFilter.isEmpty else {
            return nil
        }
        
        let formatted = targetFilter
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        
        switch type {
        case .workoutCategory:
            return "Category: \(formatted)"
        case .exerciseSpecific:
            return "Exercise: \(formatted)"
        case .muscleGroup:
            return "Muscle group: \(formatted)"
        default:
            return nil
        }
    }
}
