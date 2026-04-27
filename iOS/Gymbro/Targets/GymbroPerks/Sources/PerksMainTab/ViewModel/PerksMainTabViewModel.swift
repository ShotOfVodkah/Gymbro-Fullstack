import Foundation
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class PerksMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    
    private let router: any Router
    private let service: any PerksMainTabService
    private let analytics: any AnalyticsService
    
    init(
        router: any Router,
        service: any PerksMainTabService,
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
