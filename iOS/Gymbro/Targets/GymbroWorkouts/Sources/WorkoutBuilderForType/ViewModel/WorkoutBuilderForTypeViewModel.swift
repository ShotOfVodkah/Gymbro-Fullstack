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
    
    enum ScreenState {
        case loading
        case loaded
        case offline
        case error
    }

    init(
        networkClient: WorkoutsNetworkClient,
        router: any Router,
        divLocalRepository: DivCacheRepository,
        workoutsRepository: WorkoutsCacheRepository,
        exercisesRepository: ExercisesRepository,
        actionsRepository: OfflineActionsRepository,
        localMapper: WorkoutsLocalMapper,
        modelModifier: WorkoutsModelModifier,
        type: String?,
        workoutId: String?
    ) {
        self.router = router
        self.networkClient = networkClient
        self.divLocalRepository = divLocalRepository
        self.workoutsRepository = workoutsRepository
        self.actionsRepository = actionsRepository
        self.localMapper = localMapper
        self.modelModifier = modelModifier
        
        if let workoutId,
           let workout = workoutsRepository.loadWorkout(
                key: "user",
                workoutId: workoutId
            )
        {
            self.workout = workout
            self.screenMode = .edit
            self.selectedExercises = workout.exercises.map { ExerciseItem(from: $0)}
            self.name = workout.name
            self.type = workout.type.title
            self.workoutId = workout.id
            
            self.availableExercises = {
                if type == "Yoga"{
                    return exercisesRepository.load(type: .yoga).map(\.asExercise)
                } else if type == "Cardio"{
                    return  exercisesRepository.load(type: .cardio).map(\.asExercise)
                } else if type == "Strength"{
                    return  exercisesRepository.load(type: .strength).map(\.asExercise)
                } else {
                    return []
                }
            }()
            
            let handler = WorkoutBuilderForTypeDivUrlHandler { [weak self] link in
                self?.handle(link: link)
            }
            self.divkitComponents = DivKitComponents(urlHandler: handler)
            
            fetchData(for: workout.type.title, workout: workout)
        } else {
            self.screenMode = .create
            self.type = type!
            self.workoutId = workoutId ?? UUID().uuidString
            
            self.availableExercises = {
                if type == "Yoga"{
                    return yogaExercises
                } else if type == "Cardio"{
                    return cardioExercises
                } else if type == "Strength"{
                    return strengthExercises
                } else {
                    return []
                }
            }()
            
            let handler = WorkoutBuilderForTypeDivUrlHandler { [weak self] link in
                self?.handle(link: link)
            }
            self.divkitComponents = DivKitComponents(urlHandler: handler)
            
            fetchData(for: type!, workout: nil)
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
    }
    
    private func handle(link: WorkoutBuilderForTypeNavigationLink) {
        switch link {
        case .add(let id):
            if let exercise = availableExercises.first(where: {$0.id == id}) {
                selectedExercises.append(ExerciseItem(from: exercise))
            }
        case .remove(let id):
            if let index = selectedExercises.firstIndex(where: {$0.id == id}) {
                selectedExercises.remove(at: index)
            }
        }
    }


    func fetchData(for type: String, workout: Workout?) {
        // TODO ADD WORKOUT FETCH
        Task {
            do {
                let data = try await networkClient.fetchWorkoutBuilderForTypeDivJson(
                    with: type,
                    workout: workout
                )
                divLocalRepository.save(key: "workoutBuilderFor\(type)", data: data)
                source = DivViewSource(kind: .data(data), cardId: "WorkoutBuilder")
                modelModifier.events.send(.statusChanged(status: .online))
                screenState = .loaded
            } catch {
                guard let data = divLocalRepository.load(key: "workoutBuilderFor\(type)") else {
                    screenState = .error
                    return
                }
                if !selectedExercises.isEmpty,
                   let expandedData = localMapper.expandExercises(in: data, exerciseIds: selectedExercises.map({$0.id})) {
                    source = DivViewSource(kind: .data(expandedData), cardId: "WorkoutBuilder")
                } else {
                    source = DivViewSource(kind: .data(data), cardId: "WorkoutBuilder")
                }
                modelModifier.events.send(.statusChanged(status: .offline))
                screenState = .offline
            }
        }
    }
    
    func backButtonTapped() {
        router.pop()
    }
    
    func saveButtonTapped() {
        // TODO ADD WORKOUT SAVE
        
        var workoutType: WorkoutType {
            if type == "Yoga"{
                return .yoga
            } else if type == "Cardio"{
                return .cardio
            } else if type == "Strength"{
                return .strength
            } else {
                return .cardio
            }
        }
        
        let exercises = selectedExercises.map { $0.exercise }
        
        guard !exercises.isEmpty else {
            showAlert.toggle()
            return 
        }
        
        let workout = Workout(
            id: workoutId,
            name: name,
            type: workoutType,
            exercises: exercises
        )
        
        
        
        workoutsRepository.upsertWorkout(key: "user", workout: workout)
        switch screenMode {
        case .create:
            modelModifier.events.send(.workoutAdded(id: workoutId))
            actionsRepository.enqueueSmart(.addedWorkout(workout: WorkoutDTO(from: workout)))
            router.popToRoot()
        case .edit:
            modelModifier.events.send(.workoutEdited(id: workoutId))
            actionsRepository.enqueueSmart(.editedWorkout(workout: WorkoutDTO(from: workout)))
            router.pop()
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

    @Published var type: String
    @Published var workoutId: String
    @Published var workout: Workout?
    @Published var screenState: ScreenState = .loading
    @Published var source: DivViewSource? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())
    @Published var showAlert: Bool = false
    
    @Published var selectedExercises: [ExerciseItem] = []
    @Published var name: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var availableExercises: [any Exercise]
    private let modelModifier: WorkoutsModelModifier
    private let divLocalRepository: DivCacheRepository
    private let workoutsRepository: WorkoutsCacheRepository
    private let actionsRepository: OfflineActionsRepository
    private let localMapper: WorkoutsLocalMapper
    private let router: any Router
    private let networkClient: WorkoutsNetworkClient
    private var screenMode: ScreenMode
}
