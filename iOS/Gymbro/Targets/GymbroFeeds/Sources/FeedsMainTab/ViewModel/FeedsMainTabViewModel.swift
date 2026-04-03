import Foundation

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
    
    public init() {
        loadMockData()
    }
    
    func reload() {
        loadMockData()
    }
    
    func didTapTopLeftButton() {
        print("Mock: open friends")
    }

    func didTapCalendarButton() {
        print("Mock: open calendar")
    }

    func didTapCommunity(_ community: FeedCommunity) {
        print("Mock: open community \(community.title)")
    }

    func didTapPost(_ post: FeedPost) {
        print("Mock: open post \(post.title)")
    }

    func didTapExercise(_ exercise: FeedExercise) {
        print("Mock: open exercise \(exercise.title)")
    }

    func didTapCreate() {
        print("Mock: create content")
    }
    
    func didTapCreateCommunity() {
        print("Mock: create community")
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
