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
        let date = endDate.formatted(date: .abbreviated, time: .omitted)
        return String(format: String(localized: "challenge.formatter.until_date", bundle: .module), date)
    }
    
    static func timeLeftText(endDate: Date) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: endDate)
        let days = max(calendar.dateComponents([.day], from: start, to: end).day ?? 0, 0)
        
        if days == 0 {
            return String(localized: "challenge.formatter.ends_today", bundle: .module)
        }
        
        if days == 1 {
            return String(localized: "challenge.formatter.ends_tomorrow", bundle: .module)
        }
        
        return String(
            format: String(localized: "challenge.formatter.ends_in_days", bundle: .module),
            locale: .current,
            days
        )
    }
    
    static func formattedUnit(_ unit: String, value: Int) -> String {
        switch ChallengeUnit(rawValue: unit) {
        case .workouts:
            return value == 1
                ? String(localized: "challenge.unit.workout", bundle: .module)
                : String(localized: "challenge.unit.workouts", bundle: .module)
        case .minutes:
            return String(localized: "challenge.unit.minutes", bundle: .module)
        case .calories:
            return String(localized: "challenge.unit.calories", bundle: .module)
        case .days:
            return value == 1
                ? String(localized: "challenge.unit.day", bundle: .module)
                : String(localized: "challenge.unit.days", bundle: .module)
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
            return String(
                format: String(localized: "challenge.target.category_format", bundle: .module),
                locale: .current,
                formatted
            )
        case .exerciseSpecific:
            return String(
                format: String(localized: "challenge.target.exercise_format", bundle: .module),
                locale: .current,
                formatted
            )
        case .muscleGroup:
            return String(
                format: String(localized: "challenge.target.muscle_group_format", bundle: .module),
                locale: .current,
                formatted
            )
        default:
            return nil
        }
    }
}
