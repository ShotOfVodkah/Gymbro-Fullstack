import Foundation
import DivKit
import Combine

import GymbroNavigation
import GymbroNetwork

@MainActor
final class WorkoutsListViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case offline
        case error
    }
    
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
        localRepository: DivCacheRepository,
        router: any Router,
        modelModifier: WorkoutsModelModifier,
        localMapper: WorkoutsLocalMapper
    ) {
        self.networkClient = networkClient
        self.localRepository = localRepository
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
                case .workoutDeleted: fetchData()
                case .premadeWorkoutAdded(let id): handlePremade(id: id)
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
                let data = try await networkClient.fetchWorkoutsDivJson()
                let templates = try await networkClient.fetchWorkoutInfoTemplates()
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
                localRepository.save(key: "workoutsList", data: data)
                localRepository.save(key: "workoutInfoTemplate", data: templates)
                screenState = .loaded
            } catch {
                guard let data = localRepository.load(key: "workoutsList") else {
                    screenState = .error
                    return
                }
                source = DivViewSource(kind: .data(data), cardId: "WorkoutsCard")
                screenState = .offline
            }
        }
    }
    
    func handlePremade(id: String) {
        // TODO handle online
        guard let data = localRepository.load(key: "workoutsList"),
              let newData = localMapper.addWorkoutCard(to: data, id: id)
        else {
            return
        }
        source = DivViewSource(kind: .data(newData), cardId: DivCardID(rawValue: "WorkoutsCard_\(UUID().uuidString)"))
        sourceDebugId += 1
        localRepository.save(key: "workoutsList", data: newData)
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
    private let localRepository: DivCacheRepository
    private let router: any Router
    private let networkClient: WorkoutsNetworkClient
}
