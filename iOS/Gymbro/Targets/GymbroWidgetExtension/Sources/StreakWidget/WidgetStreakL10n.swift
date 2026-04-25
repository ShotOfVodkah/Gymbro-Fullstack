import Foundation

enum WidgetStreakL10n {
    private static let bundle = Bundle.main

    static var streakTitle: String {
        String(localized: "widget.streak.title", bundle: bundle)
    }

    static func daysLeft(_ count: Int) -> String {
        let format = NSLocalizedString(
            "widget.streak.days_remaining",
            tableName: "Localizable",
            bundle: bundle,
            value: "%lld days left",
            comment: ""
        )
        return String(format: format, locale: .current, count)
    }

    static var configurationDisplayName: String {
        String(localized: "widget.configuration.display_name", bundle: bundle)
    }

    static var configurationDescription: String {
        String(localized: "widget.configuration.description", bundle: bundle)
    }
}
