import Foundation
import DivKit

import GymbroTypes

extension WorkoutBuilderTitleNavigationLink {
    init?(url: URL) {
        guard url.scheme == "app" else { return nil }
        
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = url.host ?? ""
        
        switch host {
        case "open_builder_for_type":
            let type = comps?.queryItems?
                .first(where: { $0.name == "type" })?
                .value
            guard let type, !type.isEmpty else { return nil }
            self = .openBuilder(type: type)
        case "open_ai":
            self = .openAI
        case "open_premade":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .openPremade(id: id)
        case "save_workout":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .savePremade(id: id)
        default:
            return nil
        }
    }
}


final class WorkoutBuilderTitleDivUrlHandler: DivUrlHandler {
    private let handleNavigationLink: @MainActor (WorkoutBuilderTitleNavigationLink) -> Void


    init(handleNavigationLink: @escaping @MainActor (WorkoutBuilderTitleNavigationLink) -> Void) {
        self.handleNavigationLink = handleNavigationLink
    }

    func handle(_ url: URL, sender: AnyObject?) {
        guard let link = WorkoutBuilderTitleNavigationLink(url: url) else { return }
        Task { @MainActor in handleNavigationLink(link) }
    }
}
