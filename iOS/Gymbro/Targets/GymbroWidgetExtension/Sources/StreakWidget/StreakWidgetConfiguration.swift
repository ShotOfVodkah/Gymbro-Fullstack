import SwiftUI
import WidgetKit

import GymbroCommonUI
import GymbroTypes

struct StreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: StreakWidgetConfig.kind, provider: StreakWidgetProvider()) { entry in
            StreakWidgetView(payload: entry.payload)
        }
        .configurationDisplayName(Text(WidgetStreakL10n.configurationDisplayName))
        .description(Text(WidgetStreakL10n.configurationDescription))
        .supportedFamilies([.systemSmall])
    }
}

@main
struct GymbroWidgetBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()
    }
}
