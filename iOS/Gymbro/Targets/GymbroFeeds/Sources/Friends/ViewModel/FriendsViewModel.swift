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
    @Published var followingPeople: [PersonItem] = []
    @Published var discoverPeople: [PersonItem] = []
    @Published var selectedPerson: PersonItem?
    
    private let router: any Router
    private let service: any FeedsPeopleService
    
    init(
        router: any Router,
        service: any FeedsPeopleService,
        analytics: any AnalyticsService
    ) {
        self.router = router
        self.service = service
        reload()
        analytics.track(.screenViewed(screen: .feedsPeople))
    }
    
    func reload() {
        analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsPeople.rawValue))
        Task {
            await loadPeople()
        }
    }
    
    private func loadPeople() async {
        screenState = .loading
        
        do {
            let result = try await service.fetchScreen()
            
            friends = result.friends
            followingPeople = result.following
            discoverPeople = result.discover
            
            screenState = .loaded
        } catch {
            print("Failed to load people:", error)
            screenState = .error
        }
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
                ("Friends", filteredFriends),
                ("Following", filteredFollowingPeople),
                ("Discover", filteredDiscoverPeople)
            ]
        case .following:
            return [
                ("Following", filteredFollowingPeople),
                ("Friends", filteredFriends),
                ("Discover", filteredDiscoverPeople)
            ]
        case .discover:
            return [
                ("Discover", filteredDiscoverPeople),
                ("Following", filteredFollowingPeople),
                ("Friends", filteredFriends)
            ]
        }
    }
    
    func didTapPerson(_ person: PersonItem) {
        Task {
            do {
                selectedPerson = try await service.fetchPerson(id: person.id)
            } catch {
                print("Failed to load person:", error)
                selectedPerson = person
            }
            analytics.track(.peoplePersonOpened(personId: person.id.uuidString))
        }
    }
    
    func dismissPersonSheet() {
        selectedPerson = nil
    }
    
    func toggleFollow(for personID: String) {
        Task {
            do {
                guard let person = allPeople.first(where: { $0.id == personID }) else { return }
                try await service.toggleFollow(for: person)
                await loadPeople()
                
                if selectedPerson?.id == personID {
                    selectedPerson = allPeople.first(where: { $0.id == personID })
                }
            } catch {
                print("Failed to toggle follow:", error)
            }
        }
    }
    
    private var allPeople: [PersonItem] {
        friends + followingPeople + discoverPeople
    }
    
    func didTapViewProfile(for person: PersonItem) {
        analytics.track(.peopleProfileOpened(personId: person.id.uuidString))
        selectedPerson = nil
        router.navigate(to: .feedsProfile(title: person.name))
    }
    
    func didTapViewMessage(for person: PersonItem) {
        analytics.track(.peopleMessageOpened(personId: person.id.uuidString))
        selectedPerson = nil
        
        Task {
            do {
                let input = try await service.createDirectChat(with: person.id)
                router.navigate(to: .feedsChat(input: input))
            } catch {
                print("Failed to create direct chat:", error)
            }
        }
    }
    
    var filteredFriends: [PersonItem] {
        filter(people: friends)
    }
    
    var filteredFollowingPeople: [PersonItem] {
        filter(people: followingPeople)
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
