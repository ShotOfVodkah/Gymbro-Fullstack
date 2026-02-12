import Foundation
import DivKit

extension WorkoutsNavigationLink {
    init?(url: URL) {
        guard url.scheme == "app" else { return nil }

        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = url.host ?? ""

        switch host {
        case "open_workout":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .openWorkout(id: id)
        case "open_builder":
            self = .openBuilder
        case "open_streak":
            let current = comps?.queryItems?
                    .first(where: { $0.name == "current" })?
                    .value
                    .flatMap(Int.init)
            let goal = comps?.queryItems?
                .first(where: { $0.name == "goal" })?
                .value
                .flatMap(Int.init)
            let daysLeft = comps?.queryItems?
                .first(where: { $0.name == "daysLeft" })?
                .value
                .flatMap(Int.init)
            let total = comps?.queryItems?
                .first(where: { $0.name == "total" })?
                .value
                .flatMap(Int.init)
            guard let current, let goal, let daysLeft, let total else {
                return nil
            }
            
            self = .openStreak(current: current, goal: goal, daysLeft: daysLeft, value: total)
        default:
            return nil
        }
    }
}


final class WorkoutsDivUrlHandler: DivUrlHandler {
    private let handleNavigationLink: @MainActor (WorkoutsNavigationLink) -> Void


    init(handleNavigationLink: @escaping @MainActor (WorkoutsNavigationLink) -> Void) {
        self.handleNavigationLink = handleNavigationLink
    }


    func handle(_ url: URL, sender: AnyObject?) {
        guard let link = WorkoutsNavigationLink(url: url) else { return }
        Task { @MainActor in handleNavigationLink(link) }
    }
}
