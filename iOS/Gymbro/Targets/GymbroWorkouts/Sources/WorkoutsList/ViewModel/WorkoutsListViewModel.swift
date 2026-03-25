import Foundation
import DivKit
import Combine

import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class WorkoutsListViewModel: ObservableObject {
    
    struct StreakSheetModel: Identifiable {
        var id: Int
        
        let current: Int
        let goal: Int
        let daysLeft: Int
        let value: Int
        
        init(current: Int, goal: Int, daysLeft: Int, value: Int) {
            self.id = value
            self.current = current
            self.goal = goal
            self.daysLeft = daysLeft
            self.value = value
        }
    }

    init(
        networkClient: WorkoutsNetworkClient,
        divLocalRepository: DivCacheRepository,
        workoutsRepository: WorkoutsCacheRepository,
        exercisesRepository: ExercisesRepository,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        localMapper: WorkoutsLocalMapper
    ) {
        self.networkClient = networkClient
        self.divLocalRepository = divLocalRepository
        self.workoutsRepository = workoutsRepository
        self.exercisesRepository = exercisesRepository
        self.router = router
        self.modelModifier = modelModifier
        self.localMapper = localMapper
        
        let handler = WorkoutsDivUrlHandler{ [weak self] link in
            self?.handle(link: link)
        }
        self.divkitComponents = DivKitComponents(urlHandler: handler)
        
        modelModifier.events
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .statusChanged(let status): handleStatusChange(status: status)
                case .workoutDeleted(let id): handleDelete(id: id)
                case .premadeWorkoutAdded(let id): handleAdd(id: id, fromPremade: true)
                case .workoutAdded(id: let id): handleAdd(id: id, fromPremade: false)
                case .workoutEdited: break
                }
            }
            .store(in: &cancellables)
        
        fetchData()
    }
    
    private func handle(link: WorkoutsNavigationLink) {
           switch link {
           case .openWorkout(let id):
               router.navigate(to: .workoutInfo(id: id))
           case .openBuilder:
               router.navigate(to: .workoutBuilder)
           case .openStreak(let current, let goal, let daysLeft, let value):
               streakModel = StreakSheetModel(
                current: current,
                goal: goal,
                daysLeft: daysLeft,
                value: value
               )
           }
       }


    func fetchData() {
        Task {
            do {
                
                workoutsRepository.saveWorkouts(key: "user", workouts: workoutsMock)
                workoutsRepository.saveWorkouts(key: "premade", workouts: premadeWorkouts)
                exercisesRepository.save(type: .cardio, items: cardioExercises.map{ ExerciseItemDTO(from: $0)})
                exercisesRepository.save(type: .yoga, items: yogaExercises.map{ ExerciseItemDTO(from: $0)})
                exercisesRepository.save(type: .strength, items: strengthExercises.map{ ExerciseItemDTO(from: $0)})
                
                let data = try await networkClient.fetchWorkoutsDivJson()
                let templates = try await networkClient.fetchWorkoutInfoTemplates()
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
                divLocalRepository.save(key: "workoutsList", data: data)
                
                divLocalRepository.save(key: "workoutInfoTemplate", data: templates)
                
                modelModifier.events.send(.statusChanged(status: .online))
                screenState = .loaded
            } catch {
                guard let data = divLocalRepository.load(key: "workoutsList") else {
                    screenState = .error
                    return
                }
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
                modelModifier.events.send(.statusChanged(status: .offline))
                screenState = .offline
            }
        }
    }
    
    func handleAdd(id: String, fromPremade: Bool) {
        // TODO handle online
        guard let data = divLocalRepository.load(key: "workoutsList"),
              let newData = localMapper.addWorkoutCard(to: data, id: id, fromPremade: fromPremade)
        else {
            return
        }
        source = DivViewSource(kind: .data(newData), cardId: DivCardID(rawValue: "WorkoutsCard_\(UUID().uuidString)"))
        sourceDebugId += 1
        divLocalRepository.save(key: "workoutsList", data: newData)
    }
    
    func handleDelete(id: String) {
        // TODO handle online
        guard let data = divLocalRepository.load(key: "workoutsList"),
              let newData = localMapper.removeWorkoutCard(from: data, id: id)
        else {
            return
        }
        source = DivViewSource(kind: .data(newData), cardId: DivCardID(rawValue: "WorkoutsCard_\(UUID().uuidString)"))
        sourceDebugId += 1
        divLocalRepository.save(key: "workoutsList", data: newData)
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
    
    @Published var sourceDebugId: Int = 0
    @Published var hostingView: DivHostingView? = nil
    @Published var screenState: ScreenState = .loading
    @Published var source: DivViewSource? = nil
    @Published var divkitComponents: DivKitComponents = DivKitComponents(urlHandler: NoopDivUrlHandler())
    @Published var streakModel: StreakSheetModel? = nil
    @Published var showOfflineAlert: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let localMapper: WorkoutsLocalMapper
    private let modelModifier: WorkoutsModelModifier
    private let divLocalRepository: DivCacheRepository
    private let workoutsRepository: WorkoutsCacheRepository
    private let exercisesRepository: ExercisesRepository
    private let router: any Router
    private let networkClient: WorkoutsNetworkClient
}
