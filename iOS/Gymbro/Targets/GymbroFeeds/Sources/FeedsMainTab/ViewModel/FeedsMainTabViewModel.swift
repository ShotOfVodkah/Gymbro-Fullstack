import Foundation
import GymbroNavigation
import GymbroNetwork
import GymbroTypes

@MainActor
final class FeedsMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var selectedTab: FeedTab = .forYou {
        didSet {
            guard oldValue != selectedTab else { return }
            analytics.track(.feedsTabSelected(tab: selectedTab.rawValue))
            Task {
                await reloadPosts()
            }
        }
    }
    @Published var communities: [FeedCommunity] = []
    @Published var posts: [FeedPost] = []
    
    @Published var isShowingChatCreation: Bool = false
    @Published var chatCreationStep: ChatCreationStep = .chooseType
    @Published var chatCreationDraft = ChatCreationDraft()
    @Published var directChatSearchText: String = ""
    @Published var groupChatSearchText: String = ""
    @Published var chatCreationPeople: [PersonItem] = []
    
    @Published var isShowingCommentsSheet: Bool = false
    @Published var selectedPostForComments: FeedPost?
    @Published var comments: [FeedComment] = []
    @Published var commentsDraftText: String = ""
    @Published var isCommentsLoading: Bool = false
    @Published var isLoadingNextPage: Bool = false

    private let pageLimit = 20
    private var nextFeedCursor: Date?
    private var hasMoreFeedPosts: Bool = true
    private var isRefreshing: Bool = false
    
    private let router: any Router
    private let service: any FeedsMainTabService
    private let analytics: any AnalyticsService
    
    private let invalidationCenter: FeedsStateInvalidationCenter
    private var invalidationTask: Task<Void, Never>?
    private var communitiesPollingTask: Task<Void, Never>?
    var currentUserID: String { AppMicroservices.tokens.userId ?? "" }
    
    init(
        router: any Router,
        service: any FeedsMainTabService,
        analytics: any AnalyticsService,
        invalidationCenter: FeedsStateInvalidationCenter? = nil
    ) {
        self.router = router
        self.service = service
        self.analytics = analytics
        self.invalidationCenter = invalidationCenter ?? FeedsStateInvalidationCenter.shared

        bindInvalidationEvents()
        loadInitial()
        startCommunitiesPolling()
        
        analytics.track(.screenViewed(screen: .feedsMain))
    }
    
    deinit {
        communitiesPollingTask?.cancel()
        invalidationTask?.cancel()
    }
    
    func loadInitial() {
        Task {
            await refresh(showLoading: true)
        }
    }

    func reload() {
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsMain.rawValue))
            await refresh(showLoading: true)
        }
    }

    func refresh(showLoading: Bool = false) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        
        if showLoading {
            screenState = .loading
        }

        do {
            let screenData = try await service.fetchScreen(scope: selectedFeedScope)
            posts = screenData.posts
            communities = screenData.communities
            nextFeedCursor = screenData.nextCursor
            hasMoreFeedPosts = screenData.hasMorePosts
            screenState = .loaded
        } catch is CancellationError {
            return
        } catch {
            print("Failed to refresh feeds screen:", error)
            screenState = .error
        }
    }
    
    func reloadPosts() async {
        do {
            let page = try await service.fetchPostsPage(scope: selectedFeedScope, limit: pageLimit, cursor: nil)
            posts = page.posts
            nextFeedCursor = page.nextCursor
            hasMoreFeedPosts = page.hasMore
        } catch {
            print("Failed to reload posts:", error)
        }
    }

    func reloadCommunities() async {
        do {
            communities = try await service.fetchCommunities()
        } catch {
            print("Failed to reload communities:", error)
        }
    }

    func reloadPeople() async {
        do {
            chatCreationPeople = try await service.fetchChatCreationPeople()
        } catch {
            print("Failed to reload people:", error)
        }
    }
    
    func loadNextPageIfNeeded(currentPost post: FeedPost) {
        guard post.id == visiblePosts.last?.id else { return }
        
        Task {
            await loadNextPage()
        }
    }

    func loadNextPage() async {
        guard !isLoadingNextPage else { return }
        guard hasMoreFeedPosts else { return }
        guard let nextFeedCursor else { return }
        isLoadingNextPage = true

        do {
            let page = try await service.fetchPostsPage(
                scope: selectedFeedScope,
                limit: pageLimit,
                cursor: nextFeedCursor
            )
            
            let existingIDs = Set(posts.map(\.id))
            let newPosts = page.posts.filter { !existingIDs.contains($0.id) }
            
            posts.append(contentsOf: newPosts)
            self.nextFeedCursor = page.nextCursor
            self.hasMoreFeedPosts = page.hasMore
        } catch is CancellationError {
            return
        } catch {
            print("Failed to load next feed page:", error)
        }
        
        isLoadingNextPage = false
    }
    
    func clearUserScopedState() {
        posts = []
        communities = []
        comments = []
        commentsDraftText = ""
        selectedPostForComments = nil
        isShowingCommentsSheet = false

        chatCreationPeople = []
        chatCreationDraft = ChatCreationDraft()
        directChatSearchText = ""
        groupChatSearchText = ""
        isShowingChatCreation = false
        chatCreationStep = .chooseType
        
        nextFeedCursor = nil
        hasMoreFeedPosts = true
        isLoadingNextPage = false

        screenState = .loading
    }
    
    func didTapOpenFriends() {
        router.navigate(to: .feedsPeople(input: .mine))
    }
    
    func didTapCalendarButton() {
        router.navigate(to: .feedsCalendar(context: .mine))
    }
    
    func didTapAuthor(_ post: FeedPost) {
        analytics.track(.feedsPostAuthorTapped(postId: post.id))
        guard let userID = Int(post.authorID) else { return }
        router.navigate(to: .profileMain(mode: .otherUserProfile(userID: userID)))
        print("\(userID)")
    }
    
    var shouldShowCommunities: Bool {
        selectedTab != .forYou
    }
    
    var visibleCommunities: [FeedCommunity] {
        switch selectedTab {
        case .forYou:
            return []
        case .friends:
            return communities
        case .personal:
            return communities.filter { $0.kind == .directPerson }
        case .group:
            return communities.filter { $0.kind == .joinedGroup }
        }
    }
    
    var visiblePosts: [FeedPost] {
        posts.sorted { $0.createdAt > $1.createdAt }
    }
    
    private var selectedFeedScope: FeedScope {
        switch selectedTab {
        case .forYou:
            return .all
        case .friends:
            return .friends
        case .personal:
            return .direct
        case .group:
            return .groups
        }
    }
    
    var directChatSelectablePeople: [PersonItem] {
        filteredChatCreationPeople(searchText: directChatSearchText)
    }
    
    var groupChatSelectablePeople: [PersonItem] {
        filteredChatCreationPeople(searchText: groupChatSearchText)
    }
    
    func didTapCreateCommunity() {
        resetChatCreationDraft()
        resetChatCreationSearch()
        chatCreationStep = .chooseType
        isShowingChatCreation = true
        analytics.track(.feedsChatCreationOpened)
        Task {
            await loadChatCreationPeople()
        }
    }
    
    func dismissChatCreation() {
        isShowingChatCreation = false
        resetChatCreationDraft()
        chatCreationStep = .chooseType
        analytics.track(.feedsChatCreationDismissed)
    }
    
    func resetChatCreationState() {
        resetChatCreationDraft()
        resetChatCreationSearch()
        chatCreationPeople = []
        chatCreationStep = .chooseType
    }
    
    func didChooseDirectChat() {
        resetChatCreationDraft()
        directChatSearchText = ""
        loadChatCreationPeopleIfNeeded()
        chatCreationStep = .chooseDirectPerson
        analytics.track(.feedsChatTypeSelected(type: "direct"))
    }
    
    func didChooseGroupChat() {
        resetChatCreationDraft()
        groupChatSearchText = ""
        loadChatCreationPeopleIfNeeded()
        chatCreationStep = .createGroup
        analytics.track(.feedsChatTypeSelected(type: "group"))
    }
    
    func goBackInChatCreationFlow() {
        switch chatCreationStep {
        case .chooseType:
            dismissChatCreation()
        case .chooseDirectPerson, .createGroup:
            chatCreationStep = .chooseType
        }
    }
    
    func didSelectDirectPerson(_ person: PersonItem) {
        chatCreationDraft.selectedDirectPerson = person
        analytics.track(.feedsDirectChatPersonSelected(personId: person.id))
        openDirectChat(with: person)
    }
    
    func toggleGroupMember(_ person: PersonItem) {
        if chatCreationDraft.selectedGroupMembers.contains(person) {
            chatCreationDraft.selectedGroupMembers.removeAll { $0 == person }
        } else {
            chatCreationDraft.selectedGroupMembers.append(person)
        }
        analytics.track(.feedsGroupMemberToggled(
            personId: person.id,
            selectedCount: chatCreationDraft.selectedGroupMembers.count
        ))
    }
    
    func updateGroupName(_ name: String) {
        chatCreationDraft.groupName = name
    }
    
    var canCreateGroupChat: Bool {
        !chatCreationDraft.groupName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        && chatCreationDraft.selectedGroupMembers.count >= 2
    }
    
    func createGroupChat() {
        guard canCreateGroupChat else { return }
        
        Task {
            do {
                let input = try await service.createGroupChat(
                    title: chatCreationDraft.groupName,
                    participantIDs: chatCreationDraft.selectedGroupMembers.map(\.id)
                )
                analytics.track(.feedsGroupChatCreated(memberCount: chatCreationDraft.selectedGroupMembers.count))
                isShowingChatCreation = false
                resetChatCreationState()
                invalidationCenter.invalidate(.communitiesChanged)
                router.navigate(to: .feedsChat(input: input))
            } catch {
                print("Failed to create group chat:", error)
            }
        }
    }
    
    func didTapCommunity(_ community: FeedCommunity) {
        Task {
            do {
                let input = try await service.openExistingChat(communityID: community.id)
                analytics.track(.feedsCommunityOpened(communityId: community.id))
                router.navigate(to: .feedsChat(input: input))
            } catch {
                print("Failed to open chat:", error)
            }
        }
    }
    
    func didTapComments(for post: FeedPost) {
        selectedPostForComments = post
        isShowingCommentsSheet = true
        analytics.track(.feedsPostCommentTapped(postId: post.id))
        Task {
            await loadComments(for: post)
        }
    }
    
    func dismissCommentsSheet() {
        isShowingCommentsSheet = false
        selectedPostForComments = nil
        comments = []
        commentsDraftText = ""
        isCommentsLoading = false
    }
    
    func sendComment() {
        guard let post = selectedPostForComments else { return }
        let postID = post.serverID
        
        let text = commentsDraftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        Task {
            do {
                let newComment = try await service.createComment(postID: postID, text: text)
                comments.append(newComment)
                commentsDraftText = ""
                
                if let index = posts.firstIndex(where: { $0.id == post.id }) {
                    posts[index].commentsCount += 1
                }
                
                invalidationCenter.invalidate(.commentsChanged(postID: postID))
            } catch {
                print("Failed to send comment:", error)
            }
        }
    }
    
    func didTapExercise(_ exercise: ExerciseItem, in post: FeedPost) {
        guard let sessionID = post.sessionID else { return }
        print(sessionID)
        router.navigate(to: .workoutInfo(id: sessionID, type: .session))
    }
    
    func didTapShowAllExercises(in post: FeedPost) {
        guard let sessionID = post.sessionID else { return }
        print(sessionID)
        router.navigate(to: .workoutInfo(id: sessionID, type: .session))
    }
    
    func toggleLike(for postID: String) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        
        let oldIsLiked = posts[index].isLiked
        let oldLikesCount = posts[index].likesCount
        
        posts[index].isLiked.toggle()
        posts[index].likesCount += posts[index].isLiked ? 1 : -1
        
        Task {
            do {
                try await service.toggleLike(postID: postID, isLiked: oldIsLiked)
                analytics.track(.feedsPostLiked(postId: postID, isLiked: posts[index].isLiked))
            } catch {
                print("Failed to toggle like:", error)
                
                guard let rollbackIndex = posts.firstIndex(where: { $0.id == postID }) else { return }
                posts[rollbackIndex].isLiked = oldIsLiked
                posts[rollbackIndex].likesCount = oldLikesCount
            }
        }
    }
    
    func doubleTapLike(for postID: String) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        guard posts[index].isLiked == false else { return }

        toggleLike(for: postID)
    }
    
    private func loadChatCreationPeople() async {
        do {
            chatCreationPeople = try await service.fetchChatCreationPeople()
        } catch {
            print("Failed to load chat creation people:", error)
            chatCreationPeople = []
        }
    }
    
    private func loadChatCreationPeopleIfNeeded() {
        guard chatCreationPeople.isEmpty else { return }
        
        Task {
            await loadChatCreationPeople()
        }
    }
    
    private func loadComments(for post: FeedPost) async {
        let postID = post.serverID
        
        isCommentsLoading = true
        
        do {
            comments = try await service.fetchComments(postID: postID)
        } catch {
            print("Failed to load comments:", error)
            comments = []
        }
        
        isCommentsLoading = false
    }
    
    private func openDirectChat(with person: PersonItem) {
        Task {
            do {
                let input = try await service.createDirectChat(with: person.id)
                isShowingChatCreation = false
                resetChatCreationState()
                invalidationCenter.invalidate(.communitiesChanged)
                router.navigate(to: .feedsChat(input: input))
            } catch {
                print("Failed to create direct chat:", error)
            }
        }
    }
    
    private func filteredChatCreationPeople(searchText: String) -> [PersonItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else { return chatCreationPeople }
        
        return chatCreationPeople.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.username.localizedCaseInsensitiveContains(query) ||
            $0.status.localizedCaseInsensitiveContains(query)
        }
    }
    
    private func resetChatCreationDraft() {
        chatCreationDraft = ChatCreationDraft()
    }
    
    private func resetChatCreationSearch() {
        directChatSearchText = ""
        groupChatSearchText = ""
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
        case .feedChanged:
            await reloadPosts()

        case .communitiesChanged:
            await reloadCommunities()

        case .peopleChanged:
            await reloadPeople()

        case .chatChanged:
            await reloadCommunities()

        case .commentsChanged(let postID):
            if let selected = selectedPostForComments,
               selected.serverID == postID {
                await loadComments(for: selected)
            }
            await reloadPosts()

        case .calendarChanged:
            break

        case .accountChanged, .all:
            clearUserScopedState()
            await refresh()
        }
    }
    
    private func startCommunitiesPolling() {
        communitiesPollingTask?.cancel()

        communitiesPollingTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                await self.reloadCommunities()
            }
        }
    }
}
