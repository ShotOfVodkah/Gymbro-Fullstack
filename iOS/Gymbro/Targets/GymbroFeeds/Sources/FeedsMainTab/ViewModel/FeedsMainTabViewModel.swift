import Foundation
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
    @Published var selectedTab: FeedTab = .forYou
    @Published var communities: [FeedCommunity] = []
    @Published var posts: [FeedPost] = []
    @Published var isShowingChatCreation: Bool = false
    @Published var chatCreationStep: ChatCreationStep = .chooseType
    @Published var chatCreationDraft = ChatCreationDraft()
    @Published var directChatSearchText: String = ""
    @Published var groupChatSearchText: String = ""
    @Published var chatCreationPeople: [PersonItem] = []
    
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
        if chatCreationPeople.isEmpty {
            chatCreationPeople = FeedsPeopleMockData.friends + FeedsPeopleMockData.discover
        }
    }
    
    func didTapCreateCommunity() {
        resetChatCreationDraft()
        resetChatCreationSearch()
        chatCreationStep = .chooseType
        chatCreationPeople = FeedsPeopleMockData.friends + FeedsPeopleMockData.discover
        isShowingChatCreation = true
    }
    
    func dismissChatCreation() {
        isShowingChatCreation = false
        resetChatCreationDraft()
        chatCreationStep = .chooseType
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
    }

    func didChooseGroupChat() {
        resetChatCreationDraft()
        groupChatSearchText = ""
        loadChatCreationPeopleIfNeeded()
        chatCreationStep = .createGroup
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
            id: person.id.uuidString,
            name: person.name,
            avatarSystemName: person.avatarSystemName
        )
    }
    
    private func openChat(title: String, participants: [PersonItem]) {
        let input = ChatSessionInput(
            title: title,
            participants: participants.map(makeParticipant(from:))
        )
        
        isShowingChatCreation = false
        router.navigate(to: .feedsChat(input: input))
    }
    
    func didSelectDirectPerson(_ person: PersonItem) {
        chatCreationDraft.selectedDirectPerson = person
        openChat(title: person.name, participants: [person])
    }
    
    func toggleGroupMember(_ person: PersonItem) {
        if chatCreationDraft.selectedGroupMembers.contains(person) {
            chatCreationDraft.selectedGroupMembers.removeAll { $0 == person }
        } else {
            chatCreationDraft.selectedGroupMembers.append(person)
        }
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
        openChat(
            title: chatCreationDraft.groupName,
            participants: chatCreationDraft.selectedGroupMembers
        )
    }

    func toggleFollowInChatCreation(for personID: UUID) {
        guard let index = chatCreationPeople.firstIndex(where: { $0.id == personID }) else { return }
        chatCreationPeople[index] = chatCreationPeople[index].toggledFollow()
    }

    func didTapCommunity(_ community: FeedCommunity) {
        switch community.kind {
        case .directPerson:
            guard let person = community.participants.first else { return }
            openChat(title: person.name, participants: [person])
            
        case .joinedGroup:
            openChat(title: community.title, participants: community.participants)
        }
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
