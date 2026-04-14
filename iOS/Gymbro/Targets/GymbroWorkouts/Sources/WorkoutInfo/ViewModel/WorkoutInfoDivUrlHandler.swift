import Foundation
import DivKit

extension WorkoutInfoNavigationLink {
    init?(url: URL) {
        guard url.scheme == "app" else { return nil }
        
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = url.host ?? ""
        
        switch host {
        case "open_player":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .openPlayer(id: id)
        case "delete":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .delete(id: id)
        case "add_to_my":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .addToMy(id: id)
        case "edit":
            let id = comps?.queryItems?
                .first(where: { $0.name == "id" })?
                .value
            guard let id, !id.isEmpty else { return nil }
            self = .edit(id: id)
        default:
            return nil
        }
    }
}


final class WorkoutInfoDivUrlHandler: DivUrlHandler {
    private let handleNavigationLink: @MainActor (WorkoutInfoNavigationLink) -> Void


    init(handleNavigationLink: @escaping @MainActor (WorkoutInfoNavigationLink) -> Void) {
        self.handleNavigationLink = handleNavigationLink
    }


    func handle(_ url: URL, sender: AnyObject?) {
        guard let link = WorkoutInfoNavigationLink(url: url) else { return }
        Task { @MainActor in handleNavigationLink(link) }
    }
}
