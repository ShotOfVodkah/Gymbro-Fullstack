import SwiftUI
import WidgetKit

import GymbroTypes

struct ActivityCalendarWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: ActivityCalendarWidgetConfig.kind,
            provider: ActivityCalendarWidgetProvider()
        ) { entry in
            ActivityCalendarWidgetView(payload: entry.payload)
        }
        .configurationDisplayName(Text(WidgetActivityCalendarL10n.configurationDisplayName))
        .description(Text(WidgetActivityCalendarL10n.configurationDescription))
        .supportedFamilies([.systemMedium])
    }
}
