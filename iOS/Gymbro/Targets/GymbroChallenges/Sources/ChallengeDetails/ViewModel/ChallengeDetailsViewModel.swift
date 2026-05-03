import Foundation

import GymbroNavigation
import GymbroTypes

@MainActor
final class ChallengeDetailsViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published private(set) var details: ChallengeDetailsModel?
    @Published private(set) var activity: [ChallengeActivityModel] = []
    @Published private(set) var leaderboard: [ChallengeLeaderboardTeamModel] = []
    
    let challengeID: String
    
    private let router: any Router
    private let service: any ChallengeDetailsService
    private let analytics: any AnalyticsService
    
    init(
        challengeID: String,
        router: any Router,
        service: any ChallengeDetailsService,
        analytics: any AnalyticsService
    ) {
        self.challengeID = challengeID
        self.router = router
        self.service = service
        self.analytics = analytics
        
        reload()
        
        analytics.track(.challengeDetailsOpened(challengeId: challengeID))
        analytics.track(.screenViewed(screen: .challengeDetails))
    }
    
    func reload() {
        Task {
            await loadDetails()
        }
    }

    private func loadDetails() async {
        screenState = .loading
        
        do {
            async let detailsTask = service.fetchDetails(id: challengeID)
            async let activityTask = service.fetchActivity(challengeID: challengeID)
            async let leaderboardTask = service.fetchLeaderboard(challengeID: challengeID)
            
            details = try await detailsTask
            activity = try await activityTask
            leaderboard = try await leaderboardTask
            
            screenState = .loaded
        } catch {
            screenState = .error
        }
    }
    
    func backButtonTapped() {
        router.pop()
    }
    
    func teamActionTapped() {
        guard let details else { return }
        
        switch details.participationStatus {
        case .notJoined:
            router.navigate(to: .joinChallenge(id: challengeID))
        case .inProgress, .completed, .failed:
            if let chatID = details.team?.chatID {
                analytics.track(.challengeOpenChatTapped(challengeId: challengeID, chatId: chatID))
            }
            // later: router.navigate(to: .feedsChat(input: ...))
            break
        }
    }
    
    func leaveChallengeTapped() {
        guard let teamID = details?.team?.id else { return }
        
        Task {
            do {
                try await service.leaveChallenge(
                    challengeID: challengeID,
                    teamID: teamID
                )
                await loadDetails()
            } catch {
                screenState = .error
            }
        }
    }
    
    func joinAnotherTeamTapped() {
        router.navigate(to: .joinChallenge(id: challengeID))
    }
    
    func leaderboardTapped() {
        router.navigate(to: .challengeLeaderboard(id: challengeID))
    }
}
