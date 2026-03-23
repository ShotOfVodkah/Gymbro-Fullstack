import Foundation

import GymbroNavigation

@MainActor
final class WorkoutPlayerViewModel: ObservableObject {

    init(
        id: String,
        router: any Router
    ) {
        self.workoutId = id
        self.router = router
    }

    func backButtonTapped() {
        router.pop()
    }

    let workoutId: String

    private let router: any Router
}
