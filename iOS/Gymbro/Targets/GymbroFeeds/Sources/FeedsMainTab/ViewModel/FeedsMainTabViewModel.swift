import Foundation
import GymbroNetwork
import GymbroNavigation
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
            analytics.track(.feedsTabSelected(tab: selectedTab.rawValue))
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
    
    private let router: any Router
    private let analytics: any AnalyticsService

    init(router: any Router, analytics: any AnalyticsService) {
        self.router = router
        self.analytics = analytics
        reload()
        analytics.track(.screenViewed(screen: .feedsMain))
    }
    
    func reload() {
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsMain.rawValue))
            await loadFeed()
        }
    }
    
    func didTapOpenFriends() {
        router.navigate(to: .feedsPeople)
    }

    func didTapCalendarButton() {
        router.navigate(to: .feedsCalendar(context: .mine))
    }
    
    func didTapAuthor(_ post: FeedPost) {
        analytics.track(.feedsPostAuthorTapped(postId: post.id.uuidString))
        router.navigate(to: .feedsProfile(title: post.authorName))
    }
    
    var shouldShowCommunities: Bool {
        selectedTab != .forYou
    }
    
    var visibleCommunities: [FeedCommunity] {
        switch selectedTab {
        case .forYou:
            return []
        case .friends:
            return communities.filter { $0.kind == .directPerson || $0.kind == .joinedGroup }
        case .personal:
            return communities.filter { $0.kind == .directPerson }
        case .group:
            return communities.filter { $0.kind == .joinedGroup }
        }
    }
    
    var visiblePosts: [FeedPost] {
        switch selectedTab {
        case .forYou:
            return posts
        case .friends:
            return posts.filter { $0.kind == .friend || ($0.kind == .group && $0.isFromJoinedCommunity) }
        case .personal:
            return posts.filter { $0.kind == .friend }
        case .group:
            return posts.filter { $0.kind == .group && $0.isFromJoinedCommunity }
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
    
    var directChatSelectablePeople: [PersonItem] {
        filteredChatCreationPeople(searchText: directChatSearchText)
    }

    var groupChatSelectablePeople: [PersonItem] {
        filteredChatCreationPeople(searchText: groupChatSearchText)
    }
    
    private func resetChatCreationDraft() {
        chatCreationDraft = ChatCreationDraft()
    }

    private func resetChatCreationSearch() {
        directChatSearchText = ""
        groupChatSearchText = ""
    }

    private func loadChatCreationPeopleIfNeeded() {
        guard chatCreationPeople.isEmpty else { return }
        
        Task {
            await loadChatCreationPeople()
        }
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
    
    private func makeParticipant(from person: PersonItem) -> ChatParticipant {
        ChatParticipant(
            id: person.id,
            name: person.name,
            avatarSystemName: person.avatarSystemName
        )
    }
    
    private func openChat(title: String, participants: [PersonItem]) {
        Task {
            do {
                let input: ChatSessionInput
                
                if participants.count == 2, let person = participants.first {
                    let room = try await AppMicroservices.feeds.createDirectChat(participantID: person.id)
                    input = ChatSessionInput(response: room)
                } else {
                    let room = try await AppMicroservices.feeds.createGroupChat(
                        title: title,
                        description: "",
                        participantIDs: participants.map(\.id)
                    )
                    input = ChatSessionInput(response: room)
                }
                
                isShowingChatCreation = false
                resetChatCreationState()
                router.navigate(to: .feedsChat(input: input))
            } catch {
                print("Failed to open chat:", error)
            }
        }
    }
    
    func didSelectDirectPerson(_ person: PersonItem) {
        chatCreationDraft.selectedDirectPerson = person
        analytics.track(.feedsDirectChatPersonSelected(personId: person.id.uuidString))
        openChat(title: person.name, participants: [person])
    }
    
    func toggleGroupMember(_ person: PersonItem) {
        if chatCreationDraft.selectedGroupMembers.contains(person) {
            chatCreationDraft.selectedGroupMembers.removeAll { $0 == person }
        } else {
            chatCreationDraft.selectedGroupMembers.append(person)
        }
        analytics.track(.feedsGroupMemberToggled(
            personId: person.id.uuidString,
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
        analytics.track(.feedsGroupChatCreated(memberCount: chatCreationDraft.selectedGroupMembers.count))
        openChat(
            title: chatCreationDraft.groupName,
            participants: chatCreationDraft.selectedGroupMembers
        )
    }

    func toggleFollowInChatCreation(for personID: String) {
        guard let index = chatCreationPeople.firstIndex(where: { $0.id == personID }) else { return }
        chatCreationPeople[index] = chatCreationPeople[index].toggledFollow()
    }

    func didTapCommunity(_ community: FeedCommunity) {
        analytics.track(.feedsCommunityOpened(communityId: community.id.uuidString))
        let input = ChatSessionInput(
            chatID: community.id,
            title: community.title,
            participants: community.participants.map(makeParticipant(from:))
        )
        
        router.navigate(to: .feedsChat(input: input))
    }

    func didTapComments(for post: FeedPost) {
        analytics.track(.feedsPostCommentTapped(postId: post.id.uuidString))
        print("open comments")
//        router.navigate(to: .feedsComments(title: post.title))
    }

    func didTapExercise(_ exercise: ExerciseItem) {
        print("workout info")
    }

    func toggleLike(for postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likesCount += posts[index].isLiked ? 1 : -1
        analytics.track(.feedsPostLiked(postId: postID.uuidString, isLiked: posts[index].isLiked))
    }
    
    private func loadFeed() async {
        screenState = .loading
        
        do {
            async let feedResponse = AppMicroservices.feeds.fetchFeed()
            async let communitiesResponse = AppMicroservices.feeds.fetchCommunities()
            
            let postsResult = try await feedResponse
            let communitiesResult = try await communitiesResponse
            
            posts = postsResult.map(FeedPost.init(response:))
            communities = communitiesResult.map(FeedCommunity.init(response:))
            
            screenState = .loaded
        } catch {
            print("Failed to load feed:", error)
            screenState = .error
        }
    }
    
    private func loadChatCreationPeople() async {
        do {
            async let friendsResponse = AppMicroservices.feeds.fetchFriends()
            async let followingResponse = AppMicroservices.feeds.fetchFollowing()
            async let discoverResponse = AppMicroservices.feeds.fetchDiscoverPeople()
            
            let friends = try await friendsResponse.map(PersonItem.init(response:))
            let following = try await followingResponse.map(PersonItem.init(response:))
            let discover = try await discoverResponse.map(PersonItem.init(response:))
            
            let combined = friends + following + discover
            chatCreationPeople = uniquePeople(combined)
        } catch {
            print("Failed to load chat creation people:", error)
            chatCreationPeople = []
        }
    }
    
    private func uniquePeople(_ people: [PersonItem]) -> [PersonItem] {
        var seen = Set<String>()
        var result: [PersonItem] = []
        
        for person in people {
            if seen.contains(person.id) { continue }
            seen.insert(person.id)
            result.append(person)
        }
        
        return result
    }
}
