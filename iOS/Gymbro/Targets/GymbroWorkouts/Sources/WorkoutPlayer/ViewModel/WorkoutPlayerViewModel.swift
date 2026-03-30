import Foundation
import Combine

import GymbroNavigation
import GymbroTypes
import GymbroNetwork

@MainActor
final class WorkoutPlayerViewModel: ObservableObject {

    init(
        id: String,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        service: any WorkoutPlayerService
    ) {
        self.workoutId = id
        self.router = router
        self.service = service
        self.modelModifier = modelModifier
        
        modelModifier.events
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .statusChanged(let status): handleStatusChange(status: status)
                case .workoutEdited: Task { await self.loadWorkout() }
                case .workoutAdded, .premadeWorkoutAdded, .workoutDeleted: break
                }
            }
            .store(in: &cancellables)

        Task { await loadWorkout() }
    }

    // MARK: - Actions
    
    func loadWorkout() async {
        do {
            let (viewState, screenState) = try await service.fetchWorkout(id: workoutId)
            self.viewState = viewState
            self.screenState = screenState
            switch screenState {
            case .loaded:
                modelModifier.events.send(.statusChanged(status: .online))
            case .offline:
                modelModifier.events.send(.statusChanged(status: .offline))
            case .error, .loading:
                break
            }
        } catch {
            screenState = .error
        }
    }

    func backButtonTapped() {
        showAlert = true
    }

    func exit() {
        router.pop()
    }

    func updateWeight(exerciseId: String, weight: Double) {
        weightUpdates[exerciseId] = weight
    }

    func finishWorkout() {
        guard !isSubmitting else { return }
        isSubmitting = true
        let id = workoutId
        let name = workoutName
        let type = workoutType
        Task {
            await service.submitSession(
                workoutId: id,
                workoutName: name,
                workoutType: type,
                exercises: exercises,
                weightUpdates: weightUpdates
            )
            isSubmitting = false
            showFinishPopup = false
            modelModifier.events.send(.workoutEdited(id: id))
            router.popToRoot()
        }
    }

    // MARK: - Published state

    @Published var screenState: ScreenState = .loading
    @Published private(set) var viewState: WorkoutPlayerViewState?
    @Published var currentExerciseIndex: Int = 0
    @Published var showAlert = false
    @Published var showFinishPopup = false
    @Published private(set) var isSubmitting = false

    // MARK: - helpers

    var exercises: [ExerciseItem] { viewState?.exercises ?? [] }
    var workoutName: String { viewState?.workoutName ?? "" }
    var workoutType: WorkoutType { viewState?.workoutType ?? .strength }

    var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(currentExerciseIndex + 1) / Double(exercises.count)
    }

    var positionLabel: String {
        guard !exercises.isEmpty else { return "0 / 0" }
        return "\(currentExerciseIndex + 1) / \(exercises.count)"
    }

    var currentExercise: ExerciseItem? {
        guard exercises.indices.contains(currentExerciseIndex) else { return nil }
        return exercises[currentExerciseIndex]
    }

    var nextExercise: ExerciseItem? {
        let nextIndex = currentExerciseIndex + 1
        guard exercises.indices.contains(nextIndex) else { return nil }
        return exercises[nextIndex]
    }

    // MARK: - Private

    private func handleStatusChange(status: OfflineStatus) {
        switch screenState {
        case .loaded, .offline:
            switch status {
            case .offline: screenState = .offline
            case .online: screenState = .loaded
            }
        case .error, .loading: break
        }
    }

    private(set) var weightUpdates: [String: Double] = [:]

    let workoutId: String
    private let router: any Router
    private let service: any WorkoutPlayerService
    private let modelModifier: WorkoutsModelModifier
    private var cancellables = Set<AnyCancellable>()
}
