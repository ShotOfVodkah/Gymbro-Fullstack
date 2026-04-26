import Foundation
import WidgetKit

import GymbroTypes

final class ActivityCalendarWidgetCenterTimelineReloader: ActivityCalendarWidgetTimelineReloading {
    func reloadActivityCalendarWidgetTimelines() {
        let op = { WidgetCenter.shared.reloadTimelines(ofKind: ActivityCalendarWidgetConfig.kind) }
        if Thread.isMainThread {
            op()
        } else {
            DispatchQueue.main.async(execute: op)
        }
    }
}

final class ActivityCalendarWidgetControllingService: ActivityCalendarWidgetControlling {
    private let store: ActivityCalendarWidgetStore
    private let reloader: ActivityCalendarWidgetTimelineReloading

    init(
        store: ActivityCalendarWidgetStore,
        reloader: ActivityCalendarWidgetTimelineReloading
    ) {
        self.store = store
        self.reloader = reloader
    }

    func applySnapshot(with payload: ActivityCalendarWidgetPayload) async {
        store.save(payload)
        reloader.reloadActivityCalendarWidgetTimelines()
    }
}
