import Foundation
import GymbroNavigation
import GymbroTypes

@MainActor
final class FeedsProfilePostsViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var posts: [FeedPost] = []
    
    private let input: PostsScreenInput
    private let router: any Router
    private let service: any FeedsProfilePostsService
    private let analytics: any AnalyticsService
    
    init(
        input: PostsScreenInput,
        router: any Router,
        service: any FeedsProfilePostsService,
        analytics: any AnalyticsService
    ) {
        self.input = input
        self.router = router
        self.service = service
        self.analytics = analytics
        
        reload()
    }
    
    var title: String {
        input.isOwnProfile ? "My Posts" : "\(input.userName)'s Posts"
    }
    
    func reload() {
        Task {
            screenState = .loading
            
            do {
                posts = try await service.fetchPosts(input: input)
                screenState = .loaded
            } catch {
                posts = []
                screenState = .error
            }
        }
    }
    
    func didTapAuthor(_ post: FeedPost) {
        guard let userID = Int(post.authorID) else { return }
        router.navigate(to: .profileMain(mode: .otherUserProfile(userID: userID)))
    }
}
