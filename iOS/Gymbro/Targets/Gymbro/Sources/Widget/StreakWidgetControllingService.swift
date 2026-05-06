import Foundation
import WidgetKit

import GymbroTypes

final class StreakWidgetCenterTimelineReloader: StreakWidgetTimelineReloading {
    func reloadStreakWidgetTimelines() {
        guard #available(iOS 14.0, *) else { return }
        let op = { WidgetCenter.shared.reloadTimelines(ofKind: StreakWidgetConfig.kind) }
        if Thread.isMainThread {
            op()
        } else {
            DispatchQueue.main.async(execute: op)
        }
    }
}

final class StreakWidgetControllingService: StreakWidgetControlling {
    private let store: StreakWidgetStore
    private let reloader: StreakWidgetTimelineReloading

    init(
        store: StreakWidgetStore,
        reloader: StreakWidgetTimelineReloading,
    ) {
        self.store = store
        self.reloader = reloader
    }

    func applySnapshotFromWorkoutsListLoaded(with payload: StreakWidgetPayload) async {
        store.save(payload)
        reloader.reloadStreakWidgetTimelines()
    }

    func incrementAfterSessionSuccessfullyCreated() async {
        guard let current = store.load() else { return }
        let progressed = min(current.weeklyProgress + 1, current.weeklyTarget)
        let goalDone = progressed >= current.weeklyTarget || current.isGoalCompleted
        let next = StreakWidgetPayload(
            weeklyTarget: current.weeklyTarget,
            weeklyProgress: progressed,
            streakValue: current.streakValue,
            daysUntilBurn: current.daysUntilBurn,
            wasFreezeUsedThisWeek: current.wasFreezeUsedThisWeek,
            isGoalCompleted: goalDone
        )
        store.save(next)
        reloader.reloadStreakWidgetTimelines()
    }
}
