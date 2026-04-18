import Foundation
import GymbroAuth
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class ProfileMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var screenModel: ProfileMainScreenModel?
    @Published var relationshipState: ProfileRelationshipState?
    @Published var isLoggingOut: Bool = false
    
    let mode: ProfileViewMode
    
    private let router: any Router
    private let service: any ProfileMainTabService
    private let analytics: any AnalyticsService
    
    init(
        router: any Router,
        mode: ProfileViewMode,
        service: any ProfileMainTabService,
        analytics: any AnalyticsService
    ) {
        self.router = router
        self.mode = mode
        self.service = service
        self.analytics = analytics
        
        reload()
        analytics.track(.screenViewed(screen: .profile))
    }
    
    var isOwnProfile: Bool {
        if case .myProfile = mode { return true }
        return false
    }
    
    var profileHeader: ProfileHeaderModel? {
        screenModel?.header
    }
    
    var actions: [ProfileActionModel] {
        screenModel?.actions ?? []
    }
    
    var statsPreview: ProfileStatsPreviewModel? {
        screenModel?.statsPreview
    }
    
    var about: ProfileAboutModel? {
        screenModel?.about
    }
    
    var quickInsights: [ProfileQuickInsightModel] {
        screenModel?.quickInsights ?? []
    }
    
    var weeklyActivity: [ProfileWeeklyActivityItem] {
        screenModel?.weeklyActivity ?? []
    }
    
    var shouldShowRelationshipActions: Bool {
        !isOwnProfile
    }

    var followButtonTitle: String {
        switch relationshipState {
        case .following:
            return "Unfollow"
        case .notFollowing, .none:
            return "Follow"
        }
    }
    
    func onAppear() {
    }
    
    func reload() {
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.profile.rawValue))
            await loadProfile()
        }
    }
    
    func handleAction(_ action: ProfileActionKind) {
        switch action {
        case .editProfile:
            didTapEditProfile()
        case .settings:
            didTapSettings()
        case .posts:
            didTapPosts()
        case .friends:
            didTapFriends()
        case .workoutCalendar:
            didTapWorkoutCalendar()
        case .statistics:
            didTapStatistics()
        case .logout:
            logout()
        }
    }
    
    func didTapEditProfile() {
        guard isOwnProfile else { return }
        router.navigate(to: .profileEdit)
    }
    
    func didTapSettings() {
        guard isOwnProfile else { return }
        router.navigate(to: .profileSettings)
    }
    
    func didTapFriends() {
        switch mode {
        case .myProfile:
            router.navigate(to: .feedsPeople(input: .mine))
            
        case .otherUserProfile(let userID):
            guard let userName = screenModel?.header.fullName else { return }
            router.navigate(to: .feedsPeople(input: .user(userID: userID, userName: userName)))
        }
    }
    
    func didTapPosts() {
        guard isOwnProfile,
              let userIDString = AppMicroservices.tokens.userId,
              let userID = Int(userIDString),
              let header = screenModel?.header
        else { return }
        
        router.navigate(
            to: .feedsPosts(
                input: PostsScreenInput(
                    userID: userID,
                    userName: header.fullName,
                    isOwnProfile: true
                )
            )
        )
    }
    
    func didTapFollowButton() {
        guard case .otherUserProfile(let userID) = mode else { return }
        let oldState = relationshipState ?? .notFollowing
        relationshipState = (oldState == .following) ? .notFollowing : .following
        
        Task {
            do {
                try await service.toggleFollow(
                    for: userID,
                    isFollowing: oldState == .following
                )
            } catch {
                print("Failed to toggle follow:", error)
                relationshipState = oldState
            }
        }
    }
    
    func didTapWrite() {
        guard case .otherUserProfile(let userID) = mode else { return }
        
        Task {
            do {
                let input = try await service.createDirectChat(with: String(userID))
                router.navigate(to: .feedsChat(input: input))
            } catch {
                print("Failed to create direct chat:", error)
            }
        }
    }
    
    func didTapViewPosts() {
        guard case .otherUserProfile(let userID) = mode,
              let userName = screenModel?.header.fullName
        else { return }
        router.navigate(to: .feedsPosts(input: PostsScreenInput(userID: userID, userName: userName, isOwnProfile: false)))
    }
    
    func didTapWorkoutCalendar() {
        switch mode {
        case .myProfile:
            router.navigate(to: .feedsCalendar(context: .mine))
            
        case .otherUserProfile(let userID):
            guard let header = screenModel?.header else { return }
            router.navigate(to: .feedsCalendar(context: .person(personID: String(userID), personName: header.fullName)))
        }
    }
    
    func didTapStatistics() {
        router.navigate(to: .profileStatistics(mode: mode))
    }
    
    func logout() {
        guard isOwnProfile else { return }
        guard !isLoggingOut else { return }
        
        isLoggingOut = true
        
        Task {
            await SessionManager.shared.logout()
            analytics.track(.userLoggedOut)
            isLoggingOut = false
        }
    }
    
    private func loadProfile() async {
        screenState = .loading
        
        do {
            let model = try await service.fetchScreen(mode: mode)
            screenModel = model
            relationshipState = model.relationshipState
            screenState = .loaded
        } catch {
            print("Failed to load profile:", error)
            screenModel = nil
            screenState = .error
        }
    }
}
