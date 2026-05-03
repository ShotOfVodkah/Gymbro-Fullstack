import Foundation

import GymbroNavigation
import GymbroTypes

@MainActor
final class ChallengeLeaderboardViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case empty
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published private(set) var teams: [ChallengeLeaderboardTeamModel] = []
    
    let challengeID: String
    
    private let router: any Router
    private let service: any ChallengeLeaderboardService
    private let analytics: any AnalyticsService
    
    init(
        challengeID: String,
        router: any Router,
        service: any ChallengeLeaderboardService,
        analytics: any AnalyticsService
    ) {
        self.challengeID = challengeID
        self.router = router
        self.service = service
        self.analytics = analytics
        
        reload()
        
        analytics.track(.challengeLeaderboardOpened(challengeId: challengeID))
        analytics.track(.screenViewed(screen: .challengeLeaderboard))
    }
    
    var topThreeTeams: [ChallengeLeaderboardTeamModel] {
        Array(teams.prefix(3))
    }
    
    var otherTeams: [ChallengeLeaderboardTeamModel] {
        Array(teams.dropFirst(3))
    }
    
    func reload() {
        Task {
            await loadLeaderboard()
        }
    }

    private func loadLeaderboard() async {
        screenState = .loading
        
        do {
            teams = try await service.fetchLeaderboard(challengeID: challengeID)
                .sorted { $0.rank < $1.rank }
            
            screenState = teams.isEmpty ? .empty : .loaded
        } catch {
            screenState = .error
        }
    }
    
    func backButtonTapped() {
        router.pop()
    }
    
    func teamTapped(_ team: ChallengeLeaderboardTeamModel) {
        guard team.isCurrentUserTeam else { return }
        
        analytics.track(
                .challengeOpenChatTapped(
                    challengeId: challengeID,
                    chatId: team.chatID
                )
            )
        // later: router.navigate(to: .feedsChat(input: ...))
    }
}
