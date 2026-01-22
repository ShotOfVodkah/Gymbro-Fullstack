import Foundation
import DivKit

final class WorkoutsDivUrlHandler: DivUrlHandler {
    private let onOpenWorkout: @MainActor (String) -> Void

    init(onOpenWorkout: @escaping @MainActor (String) -> Void) {
        self.onOpenWorkout = onOpenWorkout
    }

    func handle(_ url: URL, sender: AnyObject?) {
        guard url.scheme == "app" else { return }
        guard url.host == "open_workout" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let name = components?.queryItems?.first(where: { $0.name == "name" })?.value

        guard let name, !name.isEmpty else { return }

        Task { @MainActor in
            onOpenWorkout(name)
        }
    }
}

