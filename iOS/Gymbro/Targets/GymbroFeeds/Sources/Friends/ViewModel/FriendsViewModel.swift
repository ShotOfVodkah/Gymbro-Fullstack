import SwiftUI
import Foundation
import GymbroNavigation
import GymbroTypes

@MainActor
final class FeedsPeopleViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var selectedTab: PeopleTab = .friends
    @Published var searchText: String = ""
    @Published var friends: [PersonItem] = []
    @Published var discoverPeople: [PersonItem] = []
    @Published var selectedPerson: PersonItem?
    
    private let router: any Router
    private let analytics: any AnalyticsService

    init(router: any Router, analytics: any AnalyticsService) {
        self.router = router
        self.analytics = analytics
        loadMockData()
        analytics.track(.screenViewed(screen: .feedsPeople))
    }
    
    func reload() {
        analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsPeople.rawValue))
        loadMockData()
    }
    
    private func loadMockData() {
        friends = FeedsPeopleMockData.friends
        discoverPeople = FeedsPeopleMockData.discover
        screenState = .loaded
    }
    
    func didSelectTab(_ tab: PeopleTab) {
        analytics.track(.peopleSegmentSelected(segment: tab.rawValue))
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTab = tab
        }
    }
    
    var orderedSections: [(title: String, people: [PersonItem])] {
        switch selectedTab {
        case .friends:
            return [
                ("Your friends", filteredFriends),
                ("Discover", filteredDiscoverPeople)
            ]
        case .discover:
            return [
                ("Discover", filteredDiscoverPeople),
                ("Your friends", filteredFriends)
            ]
        }
    }
    
    func didTapPerson(_ person: PersonItem) {
        selectedPerson = person
        analytics.track(.peoplePersonOpened(personId: person.id.uuidString))
    }
    
    func dismissPersonSheet() {
        selectedPerson = nil
    }
    
    func toggleFollow(for personID: UUID) {
        if let index = friends.firstIndex(where: { $0.id == personID }) {
            friends[index] = friends[index].toggledFollow()
            syncSelectedPerson(id: personID)
            analytics.track(.peopleFollowToggled(personId: personID.uuidString, isFollowing: friends[index].isFollowing))
            return
        }
        
        if let index = discoverPeople.firstIndex(where: { $0.id == personID }) {
            discoverPeople[index] = discoverPeople[index].toggledFollow()
            syncSelectedPerson(id: personID)
            analytics.track(.peopleFollowToggled(personId: personID.uuidString, isFollowing: discoverPeople[index].isFollowing))
        }
    }
    
    private func syncSelectedPerson(id: UUID) {
        guard selectedPerson?.id == id else { return }
        
        if let updated = (friends + discoverPeople).first(where: { $0.id == id }) {
            selectedPerson = updated
        }
    }
    
    func didTapViewProfile(for person: PersonItem) {
        analytics.track(.peopleProfileOpened(personId: person.id.uuidString))
        selectedPerson = nil
        router.navigate(to: .feedsProfile(title: person.name))
    }
    
    func didTapViewMessage(for person: PersonItem) {
        analytics.track(.peopleMessageOpened(personId: person.id.uuidString))
        selectedPerson = nil
        let input = ChatSessionInput(
            title: person.name,
            participants: [ChatParticipant(id: person.id.uuidString, name: person.name, avatarSystemName: person.avatarSystemName)]
        )
        router.navigate(to: .feedsChat(input: input))
    }
    
    var filteredFriends: [PersonItem] {
        filter(people: friends)
    }
    
    var filteredDiscoverPeople: [PersonItem] {
        filter(people: discoverPeople)
    }
    
    private func filter(people: [PersonItem]) -> [PersonItem] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return people
        }
        
        let query = searchText.lowercased()
        return people.filter {
            $0.name.lowercased().contains(query) ||
            $0.username.lowercased().contains(query) ||
            $0.subtitle.lowercased().contains(query) ||
            $0.status.lowercased().contains(query)
        }
    }
    
    func didTapBack() {
        router.pop()
    }
}
