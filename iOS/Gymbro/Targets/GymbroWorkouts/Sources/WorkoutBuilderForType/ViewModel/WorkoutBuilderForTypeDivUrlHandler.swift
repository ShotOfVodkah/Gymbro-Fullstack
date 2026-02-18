import Foundation
import DivKit

import GymbroTypes

extension WorkoutBuilderForTypeNavigationLink {
    init?(url: URL) {
        guard url.scheme == "app" else { return nil }
        
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = url.host ?? ""
        
        switch host {
        case "add":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .add(id: id)
        case "remove":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .remove(id: id)
        default:
            return nil
        }
    }
}


final class WorkoutBuilderForTypeDivUrlHandler: DivUrlHandler {
    private let handleNavigationLink: @MainActor (WorkoutBuilderForTypeNavigationLink) -> Void


    init(handleNavigationLink: @escaping @MainActor (WorkoutBuilderForTypeNavigationLink) -> Void) {
        self.handleNavigationLink = handleNavigationLink
    }

    func handle(_ url: URL, sender: AnyObject?) {
        guard let link = WorkoutBuilderForTypeNavigationLink(url: url) else { return }
        Task { @MainActor in handleNavigationLink(link) }
    }
}
