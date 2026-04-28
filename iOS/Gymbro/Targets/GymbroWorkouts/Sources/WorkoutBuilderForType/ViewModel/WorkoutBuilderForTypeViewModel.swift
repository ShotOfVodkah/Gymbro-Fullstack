import Foundation
import DivKit
import Combine

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class WorkoutBuilderForTypeViewModel: ObservableObject {

    enum ScreenMode {
        case create
        case edit
    }

    init(
        service: any WorkoutBuilderForTypeService,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        type: String?,
        workoutId: String?,
        analytics: any AnalyticsService
    ) {
        self.service = service
        self.router = router
        self.modelModifier = modelModifier
        self.analytics = analytics

        if let workoutId, let workout = service.loadWorkout(id: workoutId) {
            self.workout = workout
            self.screenMode = .edit
            self.selectedExercises = workout.exercises.map { ExerciseItem(from: $0) }
            self.name = workout.name
            self.workoutKind = workout.type
            self.workoutId = workout.id
            self.availableExercises = []

            let handler = WorkoutBuilderForTypeDivUrlHandler { [weak self] link in
                self?.handle(link: link)
            }
            self.divkitComponents = DivKitComponents(urlHandler: handler)

            fetchData()
        } else {
            self.screenMode = .create
            self.workoutKind = WorkoutType.resolvingBuilderTypeToken(type ?? "")
            self.workoutId = workoutId ?? UUID().uuidString
            self.availableExercises = []

            let handler = WorkoutBuilderForTypeDivUrlHandler { [weak self] link in
                self?.handle(link: link)
            }
            self.divkitComponents = DivKitComponents(urlHandler: handler)

            fetchData()
        }

        modelModifier.events
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .statusChanged(let status): handleStatusChange(status: status)
                default: break
                }
            }
            .store(in: &cancellables)

        analytics.track(.screenViewed(screen: .workoutBuilderForType))
    }

    // MARK: - Actions

    func fetchData() {
        let apiType = workoutKind.builderTypeQueryValue
        Task {
            do {
                availableExercises = await service.fetchAvailableExercises(type: apiType)
                let (data, state) = try await service.fetchScreen(
                    type: apiType,
                    workout: workout,
                    selectedExerciseIds: selectedExercises.map(\.id)
                )
                source = DivViewSource(kind: .data(data), cardId: "WorkoutBuilder")
                modelModifier.events.send(.statusChanged(status: state == .loaded ? .online : .offline))
                screenState = state
            } catch {
                analytics.track(.errorOccurred(screen: AnalyticsScreen.workoutBuilderForType.rawValue, message: error.localizedDescription))
                screenState = .error
            }
        }
    }

    func backButtonTapped() {
        router.pop()
    }

    func saveButtonTapped() {
        let exercises = selectedExercises.map { $0.exercise }
        guard !exercises.isEmpty, !name.isEmpty else {
            showAlert.toggle()
            return
        }

        let workout = Workout(id: workoutId, name: name, type: workoutKind, exercises: exercises)

        Task {
            switch screenMode {
            case .create:
                await service.saveWorkout(workout)
                await service.trackCustomWorkoutCreated()
                analytics.track(.workoutCreated(
                    workoutId: workoutId,
                    exerciseCount: exercises.count,
                    workoutType: workout.type.title
                ))
                modelModifier.events.send(.workoutAdded(id: workoutId))
                router.popToRoot()
            case .edit:
                await service.editWorkout(workout)
                modelModifier.events.send(.workoutEdited(id: workoutId))
                router.pop()
            }
        }
    }

    // MARK: - Published state

    @Published var workoutKind: WorkoutType
    @Published var workoutId: String
    @Published var workout: Workout?
    @Published var screenState: ScreenState = .loading
    @Published var source: DivViewSource? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())
    @Published var showAlert: Bool = false
    @Published var selectedExercises: [ExerciseItem] = []
    @Published var name: String = ""

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private var availableExercises: [any Exercise]
    private var screenMode: ScreenMode
    private let service: any WorkoutBuilderForTypeService
    private let modelModifier: WorkoutsModelModifier
    private let router: any Router
    private let analytics: any AnalyticsService

    private func handle(link: WorkoutBuilderForTypeNavigationLink) {
        switch link {
        case .add(let id):
            if let exercise = availableExercises.first(where: { $0.id == id }) {
                selectedExercises.append(ExerciseItem(from: exercise))
            }
        case .remove(let id):
            if let index = selectedExercises.firstIndex(where: { $0.id == id }) {
                selectedExercises.remove(at: index)
            }
        }
    }

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
}
