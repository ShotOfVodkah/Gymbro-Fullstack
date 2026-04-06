import Foundation
import GymbroNavigation

@MainActor
final class FeedsMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var selectedTab: FeedTab = .forYou
    @Published var communities: [FeedCommunity] = []
    @Published var posts: [FeedPost] = []
    
    private let router: any Router
    
    init(router: any Router) {
        self.router = router
        loadMockData()
    }
    
    func reload() {
        loadMockData()
    }
    
    func didTapOpenFriends() {
        router.navigate(to: .feedsPeople)
    }

    func didTapCalendarButton() {
        router.navigate(to: .feedsCalendar(context: .mine))
    }

    func didTapCommunity(_ community: FeedCommunity) {
        router.navigate(to: .feedsCommunity(title: community.title))
    }

    func didTapPost(_ post: FeedPost) {
        router.navigate(to: .feedsPost(title: post.title))
    }

    func didTapComments(for post: FeedPost) {
        router.navigate(to: .feedsComments(title: post.title))
    }

    func didTapExercise(_ exercise: FeedExercise) {
        router.navigate(to: .feedsExercise(title: exercise.title))
    }
    
    func didTapCreateCommunity() {
        router.navigate(to: .feedsCreateCommunity)
    }
    
    var shouldShowCommunities: Bool {
        selectedTab != .forYou
    }
    
    var visibleCommunities: [FeedCommunity] {
        switch selectedTab {
        case .forYou:
            return []
            
        case .friends:
            return communities.filter {
                $0.kind == .directPerson || $0.kind == .joinedGroup
            }
            
        case .personal:
            return communities.filter {
                $0.kind == .directPerson
            }
            
        case .group:
            return communities.filter {
                $0.kind == .joinedGroup
            }
        }
    }
    
    var visiblePosts: [FeedPost] {
        switch selectedTab {
        case .forYou:
            return posts
            
        case .friends:
            return posts.filter {
                $0.kind == .friend || ($0.kind == .group && $0.isFromJoinedCommunity)
            }
            
        case .personal:
            return posts.filter {
                $0.kind == .friend
            }
            
        case .group:
            return posts.filter {
                $0.kind == .group && $0.isFromJoinedCommunity
            }
        }
    }
    
    func toggleLike(for postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likesCount += posts[index].isLiked ? 1 : -1
    }
    
    private func loadMockData() {
        communities = FeedsMockData.communities
        posts = FeedsMockData.posts
        screenState = .loaded
    }
}
