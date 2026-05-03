import Foundation

enum WorkoutL10n {
    static func builderScreenTitle(typeName: String) -> String {
        let format = String(localized: "workout.builder.screen_title", bundle: .module)
        return String(format: format, locale: .current, typeName)
    }

    static func streakDaysLeft(_ days: Int) -> String {
        let format = String(localized: "workout.streak.days_left", bundle: .module)
        return String(format: format, locale: .current, days)
    }

    static var streakMotivationSafe: String {
        String(localized: "workout.streak.motivation.safe", bundle: .module)
    }

    static var streakMotivationDanger: String {
        String(localized: "workout.streak.motivation.danger", bundle: .module)
    }

    static var streakMotivationFreeze: String {
        String(localized: "workout.streak.motivation.freeze", bundle: .module)
    }
}
