import Foundation
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class ChallengesMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case empty
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published private(set) var challenges: [ChallengeCardModel] = []
    
    @Published var selectedFilter: ChallengeFilter = .all
    @Published var selectedCategory: ChallengeCategory = .workouts
    
    var filteredChallenges: [ChallengeCardModel] {
        challenges.filter { challenge in
            let matchesFilter: Bool
            
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .joined:
                matchesFilter = challenge.isJoined
            case .available:
                matchesFilter = !challenge.isJoined
            case .inProgress:
                matchesFilter = challenge.status == .inProgress
            case .completed:
                matchesFilter = challenge.status == .completed
            case .failed:
                matchesFilter = challenge.status == .failed
            }
            
            return matchesFilter
        }
    }
    
    var featuredChallenge: ChallengeCardModel? {
        challenges.first { $0.status == .inProgress && $0.isJoined }
        ?? challenges.first { $0.status == .notJoined }
        ?? challenges.first { $0.status == .completed }
        ?? challenges.first
    }
    
    var activeChallenges: [ChallengeCardModel] {
        filteredChallenges.filter { $0.status == .inProgress }
    }
    
    var availableChallenges: [ChallengeCardModel] {
        filteredChallenges.filter { $0.status == .notJoined }
    }
    
    var completedHistory: [ChallengeCardModel] {
        filteredChallenges.filter { $0.status == .completed || $0.status == .failed }
    }
    
    var activeCountText: String {
        "\(challenges.filter { $0.status == .inProgress }.count)"
    }
    
    var completedCountText: String {
        "\(challenges.filter { $0.status == .completed }.count)"
    }
    
    var teamsCountText: String {
        let teamNames = challenges.compactMap { $0.teamName }
        return "\(Set(teamNames).count)"
    }

    var availableCountText: String {
        "\(challenges.filter { !$0.isJoined }.count)"
    }
    
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
        reload()
        
        analytics.track(.challengeListOpened)
        analytics.track(.screenViewed(screen: .challenges))
    }
    
    func reload() {
        Task {
            await loadChallenges()
        }
    }

    func refresh() {
        analytics.track(.errorRetryTapped(screen: AnalyticsScreen.challenges.rawValue))
        Task {
            await loadChallenges()
        }
    }

    private func loadChallenges() async {
        screenState = .loading
        
        do {
            challenges = try await service.fetchChallenges()
            screenState = challenges.isEmpty ? .empty : .loaded
        } catch {
            screenState = .error
        }
    }
    
    func selectFilter(_ filter: ChallengeFilter) {
        selectedFilter = filter
        analytics.track(.challengeFilterSelected(filter: filter.rawValue))
    }
    
    func selectCategory(_ category: ChallengeCategory) {
        selectedCategory = category
    }
    
    func challengeTapped(_ challenge: ChallengeCardModel) {
        router.navigate(to: .challengeDetails(id: challenge.id))
    }

    func joinChallengeTapped(_ challenge: ChallengeCardModel) {
        router.navigate(to: .joinChallenge(id: challenge.id))
    }
}
