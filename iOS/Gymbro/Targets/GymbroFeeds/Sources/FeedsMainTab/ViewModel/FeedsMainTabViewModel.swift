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
    
    func didTapOpenFriens() {
        router.navigate(to: .feedsPeople)
    }

    func didTapCalendarButton() {
        router.navigate(to: .feedsCalendar)
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

    func didTapCreate() {
        router.navigate(to: .feedsCreatePost)
    }
    
    func didTapCreateCommunity() {
        router.navigate(to: .feedsCreateCommunity)
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
