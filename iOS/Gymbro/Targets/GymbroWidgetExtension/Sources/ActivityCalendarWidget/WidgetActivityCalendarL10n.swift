import Foundation

enum WidgetActivityCalendarL10n {
    private static let bundle = Bundle.main

    static var configurationDisplayName: String {
        String(localized: "widget.activity_calendar.configuration.display_name", bundle: bundle)
    }

    static var configurationDescription: String {
        String(localized: "widget.activity_calendar.configuration.description", bundle: bundle)
    }
    
    static var widgetHeader: String {
        String(localized: "widget.activity_calendar.widgetHeader", bundle: bundle)
    }
}
