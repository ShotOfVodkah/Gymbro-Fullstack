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
    
    private let invalidationCenter: FeedsStateInvalidationCenter
    private var invalidationTask: Task<Void, Never>?
    
    init(
        input: PostsScreenInput,
        router: any Router,
        service: any FeedsProfilePostsService,
        analytics: any AnalyticsService,
        invalidationCenter: FeedsStateInvalidationCenter? = nil
    ) {
        self.input = input
        self.router = router
        self.service = service
        self.analytics = analytics
        self.invalidationCenter = invalidationCenter ?? FeedsStateInvalidationCenter.shared
        
        bindInvalidationEvents()
        reload()
    }
    
    deinit {
        invalidationTask?.cancel()
    }
    
    var title: String {
        input.isOwnProfile ? "My Posts" : "\(input.userName)'s Posts"
    }
    
    func refresh() async {
        await loadPosts()
    }

    func clearUserScopedState() {
        posts = []
        screenState = .loading
    }

    func reload() {
        Task {
            await loadPosts()
        }
    }
    
    func didTapExercise(_ exercise: ExerciseItem, in post: FeedPost) {
        guard let sessionID = post.sessionID else { return }
        router.navigate(to: .workoutInfo(id: sessionID, type: .session))
    }

    private func loadPosts() async {
        screenState = .loading

        do {
            posts = try await service.fetchPosts(input: input)
            screenState = .loaded
        } catch {
            posts = []
            screenState = .error
        }
    }

    private func bindInvalidationEvents() {
        invalidationTask?.cancel()

        invalidationTask = Task { [weak self] in
            guard let self else { return }

            for await reason in invalidationCenter.events() {
                await self.handleInvalidation(reason)
            }
        }
    }

    private func handleInvalidation(_ reason: FeedsInvalidationReason) async {
        switch reason {
        case .feedChanged, .commentsChanged:
            await refresh()

        case .accountChanged, .all:
            clearUserScopedState()
            await refresh()

        default:
            break
        }
    }
    
//    func didTapAuthor(_ post: FeedPost) {
//        guard let userID = Int(post.authorID) else { return }
//        router.navigate(to: .profileMain(mode: .otherUserProfile(userID: userID)))
//    }
}
