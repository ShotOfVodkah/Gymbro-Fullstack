import SwiftUI
import Foundation
import GymbroNavigation
import GymbroNetwork
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
    @Published var shouldShowDiscover: Bool = true
    
    private let input: PeopleScreenInput
    private let router: any Router
    private let service: any FeedsPeopleService
    private let analytics: any AnalyticsService
    
    private let invalidationCenter: FeedsStateInvalidationCenter
    private var invalidationTask: Task<Void, Never>?
    
    var currentUserID: String { AppMicroservices.tokens.userId ?? "" }
    
    init(
        input: PeopleScreenInput,
        router: any Router,
        service: any FeedsPeopleService,
        analytics: any AnalyticsService,
        invalidationCenter: FeedsStateInvalidationCenter? = nil
    ) {
        self.input = input
        self.router = router
        self.analytics = analytics
        self.service = service
        self.invalidationCenter = invalidationCenter ?? FeedsStateInvalidationCenter.shared

        bindInvalidationEvents()
        reload()
        
        analytics.track(.screenViewed(screen: .feedsPeople))
    }
    
    deinit {
        invalidationTask?.cancel()
    }
    
    func reload() {
        analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsPeople.rawValue))
        Task {
            await loadPeople()
        }
    }
    
    func refresh() async {
        await loadPeople()
    }

    func clearUserScopedState() {
        friends = []
        followingPeople = []
        discoverPeople = []
        selectedPerson = nil
        searchText = ""
        selectedTab = .friends
        shouldShowDiscover = true
        screenState = .loading
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
            var sections: [(String, [PersonItem])] = [
                (String(localized: "feeds.section.friends", bundle: .module), filteredFriends),
                (String(localized: "feeds.section.following", bundle: .module), filteredFollowingPeople)
            ]
            if shouldShowDiscover {
                sections.append((String(localized: "feeds.section.discover", bundle: .module), filteredDiscoverPeople))
            }
            return sections
            
        case .following:
            var sections: [(String, [PersonItem])] = [
                (String(localized: "feeds.section.following", bundle: .module), filteredFollowingPeople),
                (String(localized: "feeds.section.friends", bundle: .module), filteredFriends)
            ]
            if shouldShowDiscover {
                sections.append((String(localized: "feeds.section.discover", bundle: .module), filteredDiscoverPeople))
            }
            return sections
            
        case .discover:
            guard shouldShowDiscover else {
                return [
                    (String(localized: "feeds.section.friends", bundle: .module), filteredFriends),
                    (String(localized: "feeds.section.following", bundle: .module), filteredFollowingPeople)
                ]
            }
            return [
                (String(localized: "feeds.section.discover", bundle: .module), filteredDiscoverPeople),
                (String(localized: "feeds.section.following", bundle: .module), filteredFollowingPeople),
                (String(localized: "feeds.section.friends", bundle: .module), filteredFriends)
            ]
        }
    }
    
    var title: String {
        switch input {
        case .mine:
            return "People"
        case .user(_, let userName):
            return "\(userName)'s People"
        }
    }
    
    var availableTabs: [PeopleTab] {
        shouldShowDiscover ? [.friends, .following, .discover] : [.friends, .following]
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
    
    func didTapPerson(_ person: PersonItem) {
        Task {
            do {
                selectedPerson = try await service.fetchPerson(id: person.id)
            } catch {
                print("Failed to load person:", error)
                selectedPerson = person
            }
            analytics.track(.peoplePersonOpened(personId: person.id))
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
                
                invalidationCenter.invalidate(.peopleChanged)
            } catch {
                print("Failed to toggle follow:", error)
            }
        }
    }
    
    private var allPeople: [PersonItem] {
        friends + followingPeople + discoverPeople
    }
    
    func didTapViewProfile(for person: PersonItem) {
        guard let userID = Int(person.id) else {
            print("Invalid userID: \(person.id)")
            return
        }
        router.navigate(to: .profileMain(mode: .otherUserProfile(userID: userID)))
        print("\(userID)")
        analytics.track(.peopleProfileOpened(personId: person.id))
        selectedPerson = nil
    }
    
    func didTapViewMessage(for person: PersonItem) {
        analytics.track(.peopleMessageOpened(personId: person.id))
        selectedPerson = nil
        
        Task {
            do {
                let input = try await service.createDirectChat(with: person.id)
                invalidationCenter.invalidate(.communitiesChanged)
                router.navigate(to: .feedsChat(input: input))
            } catch {
                print("Failed to create direct chat:", error)
            }
        }
    }
    
    func didTapBack() {
        router.pop()
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
        case .peopleChanged:
            await refresh()

        case .accountChanged, .all:
            clearUserScopedState()
            await refresh()

        default:
            break
        }
    }
    
    private func loadPeople() async {
        screenState = .loading
        
        do {
            let result = try await service.fetchScreen(input: input)
            
            friends = result.friends
            followingPeople = result.following
            discoverPeople = result.discover
            shouldShowDiscover = result.shouldShowDiscover
            
            if !shouldShowDiscover && selectedTab == .discover {
                selectedTab = .friends
            }
            
            screenState = .loaded
        } catch {
            print("Failed to load people:", error)
            screenState = .error
        }
    }
}
