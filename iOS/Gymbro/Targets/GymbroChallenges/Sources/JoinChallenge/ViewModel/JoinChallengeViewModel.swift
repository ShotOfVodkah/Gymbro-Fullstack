import Foundation

import GymbroNavigation
import GymbroTypes

@MainActor
final class JoinChallengeViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case success
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published private(set) var teams: [AvailableChallengeTeamModel] = []
    @Published var selectedTeam: AvailableChallengeTeamModel?
    @Published var isConfirmationPresented = false
    
    let challengeID: String
    
    private let router: any Router
    private let service: any JoinChallengeService
    private let analytics: any AnalyticsService
    
    init(
        challengeID: String,
        router: any Router,
        service: any JoinChallengeService,
        analytics: any AnalyticsService
    ) {
        self.challengeID = challengeID
        self.router = router
        self.service = service
        self.analytics = analytics
        
        reload()
        
        analytics.track(.challengeJoinOpened(challengeId: challengeID))
        analytics.track(.screenViewed(screen: .challengeJoin))
    }
    
    var availableTeamsCountText: String {
        "\(teams.filter { $0.canJoin }.count)"
    }
    
    func reload() {
        Task {
            await loadTeams()
        }
    }

    private func loadTeams() async {
        screenState = .loading
        
        do {
            teams = try await service.fetchAvailableTeams(challengeID: challengeID)
            screenState = .loaded
        } catch {
            screenState = .error
        }
    }

    func confirmJoinTapped() {
        guard let selectedTeam else { return }
        
        Task {
            do {
                try await service.joinChallenge(
                    challengeID: challengeID,
                    chatID: selectedTeam.chatID
                )
                
                isConfirmationPresented = false
                screenState = .success
                analytics.track(
                    .challengeJoined(
                        challengeId: challengeID,
                        chatId: selectedTeam.chatID
                    )
                )
            } catch {
                isConfirmationPresented = false
                screenState = .error
            }
        }
    }
    
    func teamTapped(_ team: AvailableChallengeTeamModel) {
        analytics.track(
                .challengeTeamSelected(
                    challengeId: challengeID,
                    chatId: team.chatID,
                    canJoin: team.canJoin
                )
            )
        
        guard team.canJoin else { return }
        
        selectedTeam = team
        isConfirmationPresented = true
    }
    
    func successDoneTapped() {
        router.pop()
    }
    
    func backButtonTapped() {
        router.pop()
    }
}
