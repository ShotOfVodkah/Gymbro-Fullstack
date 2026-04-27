import Foundation
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class ChallengesMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    
    private let router: any Router
    private let service: any ChallengesMainTabService
    private let analytics: any AnalyticsService
    
    init(
        router: any Router,
        service: any ChallengesMainTabService,
        analytics: any AnalyticsService
    ) {
        self.router = router
        self.service = service
        self.analytics = analytics
    }
    
    func reload() {
        screenState = .loaded
    }
}
